defmodule AccTournamentWeb.Coordinator.PickAdminLive do
  require Ecto.Query
  alias AccTournament.Levels.BeatMap
  alias Phoenix.PubSub
  alias AccTournament.Schedule.Pick
  alias AccTournament.Repo
  alias AccTournament.Schedule
  use AccTournamentWeb, :live_view

  def render(assigns) do
    assigns =
      assigns
      |> assign(
        picked_maps:
          for(%Pick{map_id: id} <- assigns.pick.match.picks, do: id)
          |> Enum.filter(&(!is_nil(&1)))
      )

    ~H"""
    <details>
      <pre><%= inspect(@picked_maps, pretty: true) %></pre>
    </details>
    <.form id="pick_settings" for={@form} method="post" phx-submit="update">
      <.input
        type="select"
        label="Pick Type"
        field={@form[:pick_type]}
        options={[{"Undecided", nil}, {"Pick", :pick}, {"Ban", :ban}]}
      />
      <.input
        type="select"
        label="Map"
        field={@form[:map_id]}
        options={
          @pick.match.round.map_pool.beat_maps
          |> Enum.filter(&(!Enum.member?(@picked_maps, &1.id) || @pick.map_id == &1.id))
          |> Enum.map(&{&1.name, &1.id})
        }
      />
      <.input type="number" field={@form[:player_1_score]} label="Player 1 score" />
      <.input type="number" field={@form[:player_2_score]} label="Player 2 score" />

      <.input
        type="select"
        label="Winning Player"
        field={@form[:winning_player_id]}
        options={[
          {"No Winner", nil},
          {@pick.match.player_1.display_name, @pick.match.player_1_id},
          {@pick.match.player_2.display_name, @pick.match.player_2_id}
        ]}
      />

      <.button type="submit">
        Save
      </.button>
    </.form>
    """
  end

  def handle_event("update", %{"pick" => values}, socket) do
    socket.assigns.pick
    |> Pick.changeset(values)
    |> IO.inspect()
    |> Repo.update()
    |> case do
      {:ok, pick} ->
        PubSub.broadcast!(AccTournament.PubSub, "stream_changed", {:stream_changed})

        {pick, stream} = get_data(pick.id)

        {:noreply, socket |> put_flash(:info, "Saved") |> assign(pick: pick, stream: stream)}

      _ ->
        {:noreply, socket |> put_flash(:error, "Failed to save")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def get_data(pick_id) do
    pick =
      Pick
      |> Ecto.Query.where(id: ^pick_id)
      |> Ecto.Query.preload(
        match: [:player_1, :picks, :player_2, round: [map_pool: [:beat_maps]]]
      )
      |> Repo.one!()

    stream =
      AccTournament.Stream
      |> Ecto.Query.where(id: 1)
      |> Ecto.Query.preload(current_match: [:player_1, :player_2, :picks])
      |> Repo.one!()

    {pick, stream}
  end

  def handle_params(%{"pick_id" => pick_id}, _uri, socket) do
    {pick, stream} = get_data(pick_id)

    {:noreply,
     socket |> assign(pick: pick, stream: stream, form: Pick.changeset(pick, %{}) |> to_form)}
  end
end
