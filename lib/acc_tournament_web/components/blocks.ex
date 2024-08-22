defmodule AccTournamentWeb.LayoutComponents do
  use AccTournamentWeb, :html

  def header_navigation,
    do: [
      %{
        label: "Home",
        navigate: ~p"/",
        route: :home
      },
      %{
        label: "Qualifiers",
        navigate: ~p"/qualifiers",
        route: :qualifiers
      },
      %{
        label: "Map Pools",
        navigate: ~p"/map_pools",
        route: :map_pools
      }
    ]

  embed_templates "blocks/*"
end
