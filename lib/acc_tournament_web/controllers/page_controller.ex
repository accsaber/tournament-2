defmodule AccTournamentWeb.PageController do
  use AccTournamentWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn
    |> assign(:route, :home)
    |> render(:home)
  end
end
