defmodule AccTournamentWeb.LayoutComponents do
  use AccTournamentWeb, :html

  def header_navigation,
    do: [
      %{
        label: "Home",
        navigate: ~p"/",
        route: :home
      }
    ]

  embed_templates "blocks/*"
end
