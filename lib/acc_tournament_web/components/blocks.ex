defmodule AccTournamentWeb.LayoutComponents do
  use AccTournamentWeb, :html

  def sigil_h(text, _opts) do
    Phoenix.HTML.Safe.to_iodata(text) |> IO.iodata_to_binary()
  end

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
