defmodule AccTournamentWeb.Coordinator.StreamAdminLive do
  require Ecto.Query
  alias Phoenix.PubSub
  alias AccTournament.Schedule.Round
  alias AccTournament.Repo
  use AccTournamentWeb, :live_view

  def render(assigns) do
    ~H"""
    <.form id="stream_config" for={@form} phx-submit="save" phx-change="save">
      <details>
        <pre><%= inspect(@stream, pretty: true) %></pre>
      </details>
      <.input
        type="select"
        field={@form[:current_round_id]}
        label="Round"
        options={
          for %{name: name, id: id} <- @rounds do
            {name, id}
          end
        }
      />
      <.input
        type="select"
        field={@form[:current_match_id]}
        label="Match"
        options={
          for %{player_1: %{display_name: p1_name}, player_2: %{display_name: p2_name}, id: id} <-
                @stream.current_round.matches do
            {"#{p1_name} vs #{p2_name}", id}
          end
        }
      />
      <.input
        :if={length(@stream.current_round.matches) > 0}
        type="select"
        field={@form[:current_pick_id]}
        label="Pick"
        options={
          for %{map: %{name: name}, id: id, pick_type: :pick} <-
                Enum.sort(@stream.current_match.picks, &(&1.id <= &2.id)) do
            {"#{id}: #{name}", id}
          end
        }
      />
    </.form>
    """
  end

  def handle_event("save", %{"stream" => stream}, socket) do
    socket.assigns.stream
    |> AccTournament.Stream.changeset(stream)
    |> Map.put(:action, :update)
    |> Repo.update()
    |> case do
      {:ok, _stream} ->
        PubSub.broadcast!(AccTournament.PubSub, "stream_changed", {:stream_changed})

        {:noreply,
         socket
         |> put_flash(:info, "saved")
         |> get_info()}

      _ ->
        {:noreply, socket |> put_flash(:error, "failed to save")}
    end
  end

  def get_info(socket) do
    alias Ecto.Query

    stream =
      AccTournament.Stream
      |> Query.preload(
        current_round: [matches: [:player_1, :player_2]],
        current_pick: [:map],
        current_match: [picks: [:map]]
      )
      |> Repo.one!()

    rounds = Round |> Repo.all()

    socket
    |> assign(
      stream: stream,
      rounds: rounds,
      form: to_form(AccTournament.Stream.changeset(stream, %{}))
    )
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> get_info()}
  end
end
