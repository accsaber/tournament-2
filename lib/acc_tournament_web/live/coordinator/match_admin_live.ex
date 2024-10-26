defmodule AccTournamentWeb.Coordinator.MatchAdminLive do
  alias AccTournament.Schedule.Round
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

  def handle_event("save", %{"match" => match}, socket) do
    socket.assigns.match
    |> Match.changeset(match)
    |> Repo.update()
    |> case do
      {:ok, match} ->
        PubSub.broadcast!(AccTournament.PubSub, "stream_changed", {:stream_changed})
        {:noreply, socket |> get_info(match.id) |> put_flash(:info, "Saved")}

      _ ->
        {:noreply, socket |> put_flash(:error, "Error saving match")}
    end
  end

  def render(assigns) do
    ~H"""
    <details open={!(@match.round && @match.player_1 && @match.player_2)}>
      <summary>Match info (don't touch this unless you are an organiser)</summary>
      <.form for={@form} id="match-info" phx-submit="save">
        <.input
          type="select"
          field={@form[:round_id]}
          label="Round"
          options={
            for %Round{name: name, id: id} <- @rounds do
              {name, id}
            end
          }
        />
        <.input
          type="select"
          field={@form[:player_1_id]}
          label="Player 1"
          options={
            for %User{display_name: name, id: id} <- @players do
              {name, id}
            end
          }
        />
        <.input
          type="select"
          field={@form[:player_2_id]}
          label="Player 2"
          options={
            for %User{display_name: name, id: id} <- @players do
              {name, id}
            end
          }
        />
        <.button type="submit">Save</.button>
      </.form>
    </details>

    <hr class="my-12 dark:border-neutral-700" />
    <details :if={@match.player_1_id && @match.player_2_id}>
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

    <form
      :if={@match.player_1 && @match.player_2}
      class="flex gap-2 flex-row"
      method="post"
      phx-submit="create_pick"
    >
      <h2 class="text-3xl">Create Pick/Ban</h2>
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

  def get_info(socket, id) do
    import Ecto.Query, only: [from: 2]

    match =
      from(match in Match,
        where: match.id == ^id,
        preload: [:player_1, :player_2, picks: [:map, :picked_by]]
      )
      |> Repo.one!()

    rounds = Round |> Repo.all()
    players = User |> Repo.all()

    changeset = match |> Match.changeset(%{})

    socket |> assign(match: match, form: to_form(changeset), players: players, rounds: rounds)
  end

  def handle_params(%{"match_id" => id}, _uri, socket) do
    {:noreply, socket |> get_info(id)}
  end
end
