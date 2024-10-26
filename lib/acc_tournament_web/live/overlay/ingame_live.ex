defmodule AccTournamentWeb.InGameLive do
  alias AccTournamentWeb.PicksBansLive
  use AccTournamentWeb, :overlay_live_view
  import AccTournamentWeb.OverlayLayoutComponents
  use LiveVue

  def render(assigns) do
    ~H"""
    <.overlay_header
      match={@stream.current_match}
      player_1_wins={@player_1_wins}
      player_2_wins={@player_2_wins}
      best_of={@best_of}
    />

    <.vue
      v-component="Pendulum"
      player_1={
        @stream.current_match.player_1.account_bindings
        |> Enum.filter(&(&1.service == :beatleader || &1.service == :scoresaber))
        |> Enum.map(&Integer.to_string(&1.platform_id))
        |> case do
          [a | _b] -> a
          _ -> nil
        end
      }
      player_2={
        @stream.current_match.player_2.account_bindings
        |> Enum.filter(&(&1.service == :beatleader || &1.service == :scoresaber))
        |> Enum.map(&Integer.to_string(&1.platform_id))
        |> case do
          [a | _b] -> a
          _ -> nil
        end
      }
    />
    """
  end

  def mount(_, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AccTournament.PubSub, "stream_changed")
    end

    {:ok,
     socket
     |> PicksBansLive.stream_info()
     |> assign(best_of: 3)}
  end
end
