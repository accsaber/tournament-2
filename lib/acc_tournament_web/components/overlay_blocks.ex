defmodule AccTournamentWeb.OverlayLayoutComponents do
  use AccTournamentWeb, :html

  def sigil_h(text, _opts) do
    Phoenix.HTML.Safe.to_iodata(text) |> IO.iodata_to_binary()
  end

  embed_templates "overlay_blocks/*"
end
