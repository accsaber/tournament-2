defmodule AccTournamentWeb.Overlay.PlayerIntroLive do
  alias AccTournament.Repo
  use AccTournamentWeb, :overlay_live_view
  import AccTournamentWeb.OverlayLayoutComponents

  def render(assigns) do
    ~H"""
    <div class="absolute inset-0 dots-container">
      <div class="dots !text-white" />
    </div>
    <.overlay_header
      match={@stream.current_match}
      player_1_wins={@player_1_wins}
      player_2_wins={@player_2_wins}
      best_of={@stream.current_round.best_of}
    />

    <div class="grid  gap-8 h-full relative" style="grid-template-columns: 1fr auto 1fr">
      <div class="flex flex-col gap-4 justify-start items-end pt-32">
        <img
          src={AccTournament.Accounts.User.public_avatar_url(@stream.current_match.player_1)}
          class="size-36 rounded shadow object-cover"
        />
        <div class="text-5xl font-semibold max-w-[40vw] overflow-hidden text-ellipsis pb-6">
          <%= @stream.current_match.player_1.display_name %>
        </div>
      </div>
      <div class="h-full w-px bg-white/20" />
      <div class="flex flex-col gap-4 justify-start items-start pt-32">
        <img
          src={AccTournament.Accounts.User.public_avatar_url(@stream.current_match.player_2)}
          class="size-36 rounded shadow object-cover"
        />
        <div class="text-5xl font-semibold max-w-[40vw] overflow-hidden text-ellipsis pb-6">
          <%= @stream.current_match.player_2.display_name %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> AccTournamentWeb.HeaderOnlyLive.stream_info()}
  end
end
