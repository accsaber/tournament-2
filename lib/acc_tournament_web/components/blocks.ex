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
      }
    ]

  embed_templates "blocks/*"
end
