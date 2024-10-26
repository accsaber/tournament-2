defmodule AccTournamentWeb.Coordinator.MatchAdminLive do
  alias AccTournament.Accounts.User
  alias Phoenix.PubSub
  alias AccTournament.Schedule.Pick
  alias AccTournament.Levels.BeatMap
  alias AccTournament.Repo
  alias AccTournament.Schedule.Match
  use AccTournamentWeb, :live_view

  def handle_event("create_pick", %{"player_id" => player_id}, socket) do
    %Pick{}
    |> Pick.changeset(%{
      picked_by_id: player_id,
      match_id: socket.assigns.match.id
    })
    |> Map.put(:action, :insert)
    |> Repo.insert()
    |> case do
      {:ok, pick} ->
        PubSub.broadcast(AccTournament.PubSub, "stream_changed", {:stream_changed})
        {:noreply, socket |> push_navigate(to: "/admin/coordinator/pick/#{pick.id}")}

      {:error, _err} ->
        {:noreply, socket |> put_flash(:error, "Failed to create pickx")}
    end
  end

  def handle_event("set_winner", %{"player" => player_id}, socket) do
    player_id =
      case player_id do
        "" -> nil
        _ -> player_id |> Integer.parse() |> elem(0)
      end

    match = socket.assigns.match

    match
    |> Match.changeset(%{winner_id: player_id})
    |> IO.inspect()
    |> Repo.update()
    |> case do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Winner set")}

      _ ->
        {:noreply, socket |> put_flash(:info, "Failed to set winner")}
    end
  end

  def render(assigns) do
    ~H"""
    <details><pre><%= inspect(@match, pretty: true) %></pre></details>
    <details>
      <summary>set winner</summary>
      <form method="post" phx-submit="set_winner">
        <div class="flex gap-2">
          <button type="submit" name="player">
            None
          </button>
          <button type="submit" name="player" value={@match.player_1_id}>
            <%= @match.player_1.display_name %>
          </button>
          <button type="submit" name="player" value={@match.player_2_id}>
            <%= @match.player_2.display_name %>
          </button>
        </div>
      </form>
    </details>
    <.table rows={@match.picks} id="picks">
      <:col :let={pick} label="Map">
        <%= case pick.map do %>
          <% nil -> %>
            <span class="opacity-60">no map</span>
          <% %BeatMap{name: name} -> %>
            <%= name %>
        <% end %>
      </:col>
      <:col :let={pick} label="Picked by">
        <%= case pick.picked_by do %>
          <% %User{display_name: name} -> %>
            <%= name %>
          <% _ -> %>
            tiebreaker
        <% end %>
      </:col>
      <:action :let={pick}>
        <.link navigate={~p"/admin/coordinator/pick/#{pick.id}"}>edit</.link>
      </:action>
    </.table>

    <h2 class="text-3xl">Create Pick/Ban</h2>
    <form class="flex gap-2 flex-row" method="post" phx-submit="create_pick">
      <.button name="player_id" value={@match.player_1_id}>
        <%= @match.player_1.display_name %>
      </.button>
      <.button name="player_id" value={@match.player_2_id}>
        <%= @match.player_2.display_name %>
      </.button>
      <.button name="player_id" value={nil}>
        tiebreaker
      </.button>
    </form>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(%{"match_id" => id}, _uri, socket) do
    import Ecto.Query, only: [from: 2]

    match =
      from(match in Match,
        where: match.id == ^id,
        preload: [:player_1, :player_2, picks: [:map, :picked_by]]
      )
      |> Repo.one!()

    {:noreply, socket |> assign(match: match)}
  end
end
