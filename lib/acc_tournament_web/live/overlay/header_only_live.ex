defmodule AccTournamentWeb.HeaderOnlyLive do
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
      best_of={@stream.current_round.best_of}
    />
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

  defp diff_name(1), do: "Easy"
  defp diff_name(3), do: "Normal"
  defp diff_name(5), do: "Hard"
  defp diff_name(7), do: "Expert"
  defp diff_name(9), do: "Expert+"
  defp diff_name(id), do: id |> Integer.to_string()
end
