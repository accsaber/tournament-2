defmodule AccTournamentWeb.OAuthLoginController do
  require Logger
  alias AccTournament.Accounts.Binding
  alias AccTournament.Repo
  alias AccTournamentWeb.UserAuth
  use AccTournamentWeb, :controller
  alias AccTournament.BeatleaderLogin
  import Ecto.Query, only: [from: 2]

  def create_binding(service, platform_id, user_id, username) do
    from(b in Binding, where: b.service == ^service and b.platform_id == ^platform_id)
    |> Repo.one()
    |> case do
      nil ->
        Binding.changeset(%Binding{}, %{
          service: service,
          platform_id: platform_id,
          user_id: user_id,
          username: username
        })
        |> Repo.insert(returning: true)

      existing_binding ->
        {:error, existing_binding}
    end
  end

  def redirect_uri(service) when is_atom(service),
    do: redirect_uri(service |> Atom.to_string())

  def redirect_uri(service),
    do:
      Application.fetch_env!(:acc_tournament, :redirect_url_prefix)
      |> URI.append_path("/" <> URI.encode(service))

  def beatleader(conn, %{"code" => login_token, "iss" => beatleader_url}) do
    client_id =
      Application.fetch_env!(:acc_tournament, :beatleader_client_id) ||
        raise("""
        BeatLeader client ID is missing.
        """)

    client_secret =
      Application.fetch_env!(:acc_tournament, :beatleader_client_secret) ||
        raise("""
        BeatLeader client secret is missing.
        """)

    client =
      OAuth2.Client.new(
        strategy: OAuth2.Strategy.AuthCode,
        client_id: client_id,
        client_secret: client_secret,
        site: beatleader_url,
        authorize_url: "oauth2/authorize",
        token_url: "oauth2/token",
        redirect_uri: redirect_uri(:beatleader)
      )

    %OAuth2.Response{
      status_code: 200,
      body: body
    } =
      client
      |> OAuth2.Client.post!(
        "oauth2/token",
        %{
          grant_type: "authorization_code",
          client_id: Application.fetch_env!(:acc_tournament, :beatleader_client_id),
          client_secret: client_secret,
          code: login_token,
          redirect_uri: redirect_uri(:beatleader)
        },
        [{"Content-Type", "application/x-www-form-urlencoded"}]
      )

    token = Jason.decode!(body) |> OAuth2.AccessToken.new()

    client = %{client | token: token}

    %OAuth2.Response{
      status_code: 200,
      body: identity
    } =
      client
      |> OAuth2.Client.get!("oauth2/identity")

    identity = Jason.decode!(identity)

    case conn.assigns do
      %{current_user: %{id: user_id}} ->
        create_binding(:beatleader, identity["id"], user_id, identity["name"])
        |> case do
          {:ok, %Binding{}} ->
            conn
            |> put_flash(:info, "BeatLeader account linked successfully")
            |> redirect(to: ~p"/users/settings")

          {:error, %Binding{}} ->
            conn
            |> put_flash(:error, "BeatLeader account already linked")
            |> redirect(to: ~p"/users/settings")

          {:error, _} ->
            conn
            |> put_flash(:error, "Error linking BeatLeader account")
            |> redirect(to: ~p"/users/settings")
        end

      _ ->
        user = identity |> BeatleaderLogin.get_user_by_identity()

        case user do
          nil ->
            conn
            |> put_session(:user_return_to, ~p"/users/settings")
            |> UserAuth.log_in_user(BeatleaderLogin.create_user_from_beatleader_profile(identity))

          _ ->
            conn
            |> UserAuth.log_in_user(user)
        end
    end

    conn |> put_resp_content_type("text/plain") |> resp(:ok, "ok")
  end

  def beatleader(_conn, _params) do
    raise AccTournamentWeb.OAuthLoginController.MissingParams
  end

  def discord(conn, %{"code" => login_token}) do
    access_token =
      Req.post!("https://discord.com/api/oauth2/token",
        form: %{
          grant_type: "authorization_code",
          code: login_token,
          redirect_uri: redirect_uri(:discord),
          client_id: Application.fetch_env!(:acc_tournament, :discord_client_id),
          client_secret: Application.fetch_env!(:acc_tournament, :discord_client_secret)
        }
      )
      |> case do
        %{status: 200, body: %{"access_token" => access_token}} -> access_token
        _ -> raise(AccTournamentWeb.OAuthLoginController.InvalidCode)
      end

    %{status: 200, body: me} =
      Req.get!("https://discord.com/api/users/@me",
        headers: [{"Authorization", "Bearer #{access_token}"}]
      )

    current_user = conn.assigns.current_user.id

    create_binding(:discord, me["id"] |> Integer.parse() |> elem(0), current_user, me["username"])
    |> case do
      {:ok, %Binding{user_id: ^current_user}} ->
        conn
        |> put_flash(:info, "Discord account linked successfully")
        |> redirect(to: ~p"/users/settings")

      {:error, %Binding{}} ->
        conn
        |> put_flash(:error, "Discord account already linked")
        |> redirect(to: ~p"/users/settings")

      {:error, _} ->
        conn
        |> put_flash(:error, "Error linking Discord account")
        |> redirect(to: ~p"/users/settings")
    end
  end

  def discord(conn, _params) do
    {:ok,
     conn
     |> put_flash(:error, "Discord linking was cancelled")
     |> redirect(to: ~p"/users/settings")}
  end

  def twitch(conn, %{"code" => login_token}) do
    access_token =
      Req.post!("https://id.twitch.tv/oauth2/token",
        form: %{
          grant_type: "authorization_code",
          code: login_token,
          redirect_uri: redirect_uri(:twitch),
          client_id: Application.fetch_env!(:acc_tournament, :twitch_client_id),
          client_secret: Application.fetch_env!(:acc_tournament, :twitch_client_secret)
        }
      )
      |> case do
        %{status: 200, body: %{"access_token" => access_token}} -> access_token
        _ -> raise(AccTournamentWeb.OAuthLoginController.InvalidCode)
      end

    %{status: 200, body: %{"data" => [me]}} =
      Req.get!("https://api.twitch.tv/helix/users",
        headers: [
          {"Authorization", "Bearer #{access_token}"},
          {"Client-ID", Application.fetch_env!(:acc_tournament, :twitch_client_id)}
        ]
      )

    create_binding(
      :twitch,
      me["id"] |> Integer.parse() |> elem(0),
      conn.assigns.current_user.id,
      me["login"]
    )
    |> case do
      {:ok, %Binding{}} ->
        conn
        |> put_flash(:info, "Twitch account linked successfully")
        |> redirect(to: ~p"/users/settings")

      {:error, %Binding{}} ->
        conn
        |> put_flash(:error, "Twitch account already linked")
        |> redirect(to: ~p"/users/settings")

      {:error, _} ->
        conn
        |> put_flash(:error, "Error linking Twitch account")
        |> redirect(to: ~p"/users/settings")
    end
  end

  def twitch(conn, _params) do
    {:ok,
     conn
     |> put_flash(:error, "Twitch linking failed")
     |> redirect(to: ~p"/users/settings")}
  end
end

defmodule AccTournamentWeb.OAuthLoginController.MissingParams do
  defexception message: "Invalid URL parameters", plug_status: 400
end

defmodule AccTournamentWeb.OAuthLoginController.InvalidCode do
  defexception message: "Invalid OAuth Code", plug_status: 400
end
