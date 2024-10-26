defmodule AccTournamentWeb.PicksBansLive do
  alias AccTournament.Levels.BeatMap
  alias AccTournament.Accounts.User
  alias AccTournament.Schedule.Match
  use AccTournamentWeb, :overlay_live_view
  import AccTournamentWeb.OverlayLayoutComponents
  alias AccTournament.Repo
  alias AccTournament.Stream

  def render(assigns) do
    assigns =
      assigns
      |> assign(
        best_of: 3,
        picks:
          case assigns.stream do
            %Stream{current_match: %Match{picks: picks}} -> picks |> Enum.sort(&(&1.id < &2.id))
            _ -> nil
          end
      )

    ~H"""
    <.overlay_header
      match={@stream.current_match}
      player_1_wins={@player_1_wins}
      player_2_wins={@player_2_wins}
      best_of={@best_of}
    />
    <div class="pick-grid p-4 px-12 gap-2">
      <%= for pick <- @picks do %>
        <%= case pick.pick_type do %>
          <% :pick -> %>
            <div class="flex flex-col p-2 py-2 gap-2 w-16 items-center rounded fade-in bg-green-500 text-black">
              <div class="size-12 flex items-center justify-center">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="2"
                  stroke="currentColor"
                  class="size-10"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
                </svg>
              </div>
              <img src={BeatMap.cover_url(pick.map)} class="rounded-sm size-12" />
            </div>
            <pick-info
              :if={
                pick.map_id &&
                  (@best_of <= 3 || !pick.winning_player_id)
              }
              class="flex flex-col rounded row-span-3 w-56 bg-neutral-950 h-96 p-5 relative overflow-hidden"
            >
              <img src={BeatMap.cover_url(pick.map)} class="size-32 scale-150 absolute blur-xl " />
              <img src={BeatMap.cover_url(pick.map)} class="size-32 rounded mb-3 relative" />
              <div class="text-xl font-semibold relative"><%= pick.map.name %></div>
              <div class="text-xl relative whitespace-nowrap w-full text-ellipsis">
                <%= pick.map.artist %>
              </div>
              <div class="text-xl relative"><%= pick.map.mapper %></div>
              <hr class="border-white/10 mt-auto" />
              <div class="text-lg relative mt-2 opacity-50">!bsr <%= pick.map.beatsaver_id %></div>
            </pick-info>
          <% :ban -> %>
            <div class="flex p-2 py-2 gap-2 items-center rounded bg-neutral-950 fade-in my-auto w-max flex-col">
              <div class="size-12 flex items-center justify-center">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="2"
                  stroke="currentColor"
                  class="size-10"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                </svg>
              </div>
              <img src={BeatMap.cover_url(pick.map)} class="rounded-sm size-12" />
            </div>
          <% _ -> %>
            <div class="bg-black/30 backdrop-blur mb-auto p-2 flex flex-col items-center gap-2 rounded">
              <img
                :if={pick.picked_by}
                src={User.public_avatar_url(pick.picked_by)}
                class="rounded size-12"
              />
              <div class="size-12 flex items-center justify-center">
                <img src={~p"/images/pulse_white.svg"} />
              </div>
            </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def mount(_, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AccTournament.PubSub, "stream_changed")
    end

    {:ok,
     socket
     |> stream_info()}
  end

  def handle_info(
        {:stream_changed},
        socket
      ) do
    {:noreply, socket |> stream_info()}
  end

  def stream_info(socket) do
    import Ecto.Query, only: [where: 2, preload: 2]

    stream =
      Stream
      |> preload([
        :current_round,
        :caster_1,
        :caster_2,
        current_match: [
          player_1: [:account_bindings],
          player_2: [:account_bindings],
          picks: [:picked_by, map: :category]
        ]
      ])
      |> where(id: ^1)
      |> Repo.one()

    case stream.current_match do
      %Match{} ->
        player_1_wins =
          AccTournament.Schedule.Pick
          |> where(match_id: ^stream.current_match.id)
          |> where(winning_player_id: ^stream.current_match.player_1_id)
          |> Repo.all()
          |> length()

        player_2_wins =
          AccTournament.Schedule.Pick
          |> where(match_id: ^stream.current_match.id)
          |> where(winning_player_id: ^stream.current_match.player_2_id)
          |> Repo.all()
          |> length()

        socket
        |> assign(stream: stream, player_1_wins: player_1_wins, player_2_wins: player_2_wins)

      _ ->
        socket |> assign(stream: stream, player_1_wins: 0, player_2_wins: 0)
    end
  end
end
