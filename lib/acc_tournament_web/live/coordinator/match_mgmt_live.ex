defmodule AccTournamentWeb.Coordinator.MatchMgmtLive do
  alias AccTournament.Repo
  alias AccTournament.Schedule.Match
  use AccTournamentWeb, :live_view

  def render(assigns) do
    ~H"""
    <.table id="match-listing" rows={@matches}>
      <:col :let={match} label="Round">
        <%= if(!is_nil(match.round), do: match.round.name) %>
      </:col>
      <:col :let={match} label="Player 1">
        <%= if(!is_nil(match.player_1), do: match.player_1.display_name) %>
      </:col>
      <:col :let={match} label="Player 2">
        <%= if(!is_nil(match.player_2), do: match.player_2.display_name) %>
      </:col>
      <:action :let={match}>
        <.link navigate={~p"/admin/coordinator/match/#{match.id}"}>Coordinator Page</.link>
      </:action>
    </.table>
    <.button phx-click="new_match">Create a new match</.button>
    """
  end

  def handle_event("new_match", %{}, socket) do
    %Match{}
    |> Match.changeset(%{})
    |> Map.put(:action, :insert)
    |> Repo.insert()
    |> case do
      {:ok, %Match{id: id}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Match Created")
         |> push_navigate(to: ~p"/admin/coordinator/match/#{id}")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Failed to create match")}
    end
  end

  def mount(_params, _session, socket) do
    import Ecto.Query, only: [preload: 2, order_by: 2]

    matches =
      Match
      |> preload([:round, :player_1, :player_2])
      |> order_by(asc: :round_id)
      |> Repo.all()

    {:ok, socket |> assign(matches: matches)}
  end
end
