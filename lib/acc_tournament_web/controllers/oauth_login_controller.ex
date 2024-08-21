defmodule AccTournamentWeb.OAuthLoginController do
  require Logger
  alias AccTournamentWeb.UserAuth
  use AccTournamentWeb, :controller
  alias AccTournament.BeatleaderLogin

  def redirect_uri, do: Application.fetch_env!(:acc_tournament, :beatleader_redirect_uri)

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
        redirect_uri: redirect_uri()
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
          redirect_uri: redirect_uri()
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
        |> UserAuth.log_in_user(BeatleaderLogin.create_user_from_beatleader_profile(identity))

      _ ->
        conn
        |> UserAuth.log_in_user(user)
    end
  end

  def beatleader(_conn, _params) do
    raise AccTournamentWeb.OauthLoginLive.MissingParams
  end
end

defmodule AccTournamentWeb.OauthLoginLive.MissingParams do
  defexception message: "Invalid URL parameters", plug_status: 400
end
