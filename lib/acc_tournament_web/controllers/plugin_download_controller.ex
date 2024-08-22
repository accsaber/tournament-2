defmodule AccTournamentWeb.PluginDownloadController do
  alias AccTournament.Repo
  use AccTournamentWeb, :controller

  def download(conn, _) do
    user = conn.assigns.current_user

    config = Application.get_env(:acc_tournament, AccTournamentWeb.Endpoint)

    # lifetime = 1_711_281_600 - System.os_time(:second)
    lifetime = 31_556_952

    {login_token, object} = AccTournament.Accounts.UserToken.build_session_token(user)

    Repo.insert!(object)

    token =
      Plug.Crypto.encrypt(config[:secret_key_base], "token", login_token, max_age: lifetime)

    {:ok, {filename, zip}} =
      :zip.create(
        "Qualifiers-#{user.slug}.zip",
        [
          {~c"UserData/ACCQualifiers/scary/DO_NOT_SHARE.SCARY", token}
        ],
        [:memory]
      )

    conn
    |> Plug.Conn.put_resp_header("Content-Type", "application/x-zip")
    |> Plug.Conn.put_resp_header(
      "Content-Disposition",
      "attachment; filename=\"" <> filename <> "\""
    )
    |> resp(:ok, zip)
  end
end
