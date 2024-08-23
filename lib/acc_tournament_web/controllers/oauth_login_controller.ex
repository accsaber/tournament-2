defmodule AccTournamentWeb.OAuthLoginController do
  require Logger
  alias AccTournament.Accounts.Binding
  alias AccTournament.Repo
  alias AccTournamentWeb.UserAuth
  use AccTournamentWeb, :controller
  alias AccTournament.BeatleaderLogin

  def beatleader_redirect_uri,
    do: Application.fetch_env!(:acc_tournament, :beatleader_redirect_uri)

  def discord_redirect_uri,
    do: Application.fetch_env!(:acc_tournament, :discord_redirect_uri)

  def beatleader(conn, %{"code" => login_token, "iss" => beatleader_url}) do
    Logger.debug(beatleader_url)

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
        redirect_uri: beatleader_redirect_uri()
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
          redirect_uri: beatleader_redirect_uri()
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

  def beatleader(_conn, _params) do
    raise AccTournamentWeb.OAuthLoginController.MissingParams
  end

  def discord(conn, %{"code" => login_token}) do
    access_token =
      Req.post!("https://discord.com/api/oauth2/token",
        form: %{
          grant_type: "authorization_code",
          code: login_token,
          redirect_uri: discord_redirect_uri(),
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

    Binding.changeset(%Binding{}, %{
      service: :discord,
      platform_id: me["id"] |> Integer.parse() |> elem(0),
      user_id: conn.assigns.current_user.id
    })
    |> Repo.insert!(on_conflict: :nothing)

    conn
    |> redirect(to: ~p"/users/settings")
  end

  def discord(_conn, _params) do
    raise AccTournamentWeb.OAuthLoginController.MissingParams
  end
end

defmodule AccTournamentWeb.OAuthLoginController.MissingParams do
  defexception message: "Invalid URL parameters", plug_status: 400
end

defmodule AccTournamentWeb.OAuthLoginController.InvalidCode do
  defexception message: "Invalid OAuth Code", plug_status: 400
end
