defmodule AccTournamentWeb.ApiUserController do
  use AccTournamentWeb, :controller

  def whoami(conn, _args) do
    conn |> render(:user_basic, player: conn.assigns.current_user)
  end
end
