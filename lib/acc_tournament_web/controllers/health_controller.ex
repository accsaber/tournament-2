defmodule AccTournamentWeb.HealthController do
  use AccTournamentWeb, :controller

  def index(conn, _args) do
    conn |> resp(:ok, "ok")
  end
end
