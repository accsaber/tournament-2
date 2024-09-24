defmodule AccTournamentWeb.MapLeaderboardLive do
  alias AccTournament.Levels.MapPool
  alias AccTournament.Qualifiers.Attempt
  alias AccTournament.Levels.BeatMap
  alias AccTournament.Accounts.User
  import AccTournamentWeb.QualifierLeaderboardLive, only: [qualifier_header: 1]

  alias AccTournament.Repo
  use AccTournamentWeb, :live_view
  import Ecto.Query, only: [from: 2, subquery: 1]
  import Ecto.Multi, only: [one: 3, all: 3]

  def difficulty_to_class(1), do: "bg-green-600 text-white"
  def difficulty_to_class(3), do: "bg-blue-500 text-white"
  def difficulty_to_class(5), do: "bg-orange-500 text-white"
  def difficulty_to_class(7), do: "bg-red-500 text-white"
  def difficulty_to_class(9), do: "bg-purple-500 text-white"
  def difficulty_to_class(id), do: id |> Integer.to_string()

  def render(assigns) do
    ~H"""
    <div class="dots-container absolute inset-0 overflow-hidden -top-8 h-96">
      <div class="absolute -inset-6 bottom-0 blur-[1.5rem] saturate-150">
        <img class="object-cover w-full h-full" src={BeatMap.cover_url(@map)} />
      </div>
      <div class="dots" />
    </div>
    <.qualifier_header qualifier_pool={@qualifier_pool} current_route={{:map, @map.id}} />
    <div class="flex flex-col md:flex-row md:items-center gap-4 card relative max-w-screen-lg mx-auto  shadow-xl">
      <img
        src={BeatMap.cover_url(@map)}
        class={[
          "rounded-xl size-24 md:size-36 aspect-square",
          difficulty_to_class(@map.difficulty)
        ]}
      />
      <div class="flex flex-col gap-1">
        <div class="text-3xl font-semibold"><%= @map.name %></div>
        <div class="flex gap-1">
          <div class={[
            "p-1 px-2 rounded w-max text-sm font-semibold",
            difficulty_to_class(@map.difficulty)
          ]}>
            <%= BeatMap.difficulty_int_to_friendly(@map.difficulty) %>
          </div>
          <div
            :if={@map.category}
            class={[
              "p-1 px-2 rounded w-max text-sm font-semibold",
              "bg-neutral-100 dark:bg-neutral-900"
            ]}
          >
            <%= @map.category.name %>
          </div>
        </div>
        <div class="flex flex-row gap-2">
          <div><%= @map.artist %></div>
          <div>&bull;</div>
          <div>Mapped by <strong class="font-semibold"><%= @map.mapper %></strong></div>
        </div>
        <div class="flex gap-0.5">
          <div class="select-all px-2 h-8 flex items-center bg-neutral-100 dark:bg-neutral-900 rounded-l w-fit font-mono">
            !bsr <%= @map.beatsaver_id %>
          </div>
          <a
            href={"https://beatsaver.com/maps/#{@map.beatsaver_id}"}
            class={[
              "flex items-center justify-center",
              "bg-neutral-100 hover:bg-neutral-200 dark:bg-neutral-900 dark:hover:bg-neutral-700 rounded-r w-8 h-8"
            ]}
          >
            <img src={~p"/images/beatsaver.svg"} class="h-4 w-4 dark:invert" />
          </a>
        </div>
      </div>
    </div>
    <div class="relative max-w-screen-lg mx-auto p-6">
      <.table rows={@attempts} id={"#{@map.id}-attempts"}>
        <:col :let={{rank, _attempt}} label="#">
          <%= rank %>
        </:col>
        <:col :let={{_rank, attempt}} label="Player">
          <.link
            navigate={"#{attempt.player}"}
            class="flex gap-2 items-center relative font-semibold underline"
          >
            <img src={User.public_avatar_url(attempt.player)} class="h-6 w-6 rounded-full absolute" />
            <div class="w-full ml-8">
              <%= attempt.player.display_name %>
            </div>
          </.link>
        </:col>
        <:col :let={{_rank, attempt}} label="Score">
          <%= attempt.score |> Number.Delimit.number_to_delimited(precision: 0) %>
        </:col>
        <:col :let={{_rank, attempt}} label="Accuracy">
          <%= (attempt.score / @map.max_score * 100) |> :erlang.float_to_binary(decimals: 2) %>%
        </:col>
        <:col :let={{_rank, attempt}} label="Weight">
          <%= if(!is_nil(attempt.weight), do: attempt.weight |> :erlang.float_to_binary(decimals: 2)) %>
        </:col>
        <:col :let={{_rank, attempt}} label="Time Set">
          <div class="relative w-max group/tooltip cursor-help">
            <datetime-tooltip timestamp={attempt.updated_at}>
              <%= Timex.from_now(attempt.updated_at) %>
            </datetime-tooltip>
            <div class={[
              "absolute top-6 left-1/2 -translate-x-1/2 w-max bg-white rounded",
              "px-2 py-1 dark:bg-neutral-800 opacity-0 pointer-events-none shadow",
              "group-hover/tooltip:opacity-100 transition-opacity group-hover/tooltip:delay-700"
            ]}>
              <local-datetime><%= attempt.updated_at %>Z</local-datetime>
            </div>
          </div>
        </:col>
        <:action :let={{_rank, attempt}}>
          <.link navigate={"#{attempt.player}"} class="text-sm font-semibold">
            Profile
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def handle_info({:new_scores, map_id}, socket) do
    case socket.assigns.map do
      %{id: ^map_id} ->
        attempts = attempts_query(map_id) |> Repo.all()
        {:noreply, socket |> assign(attempts: attempts)}

      _ ->
        {:noreply, socket}
    end
  end

  def mount(_, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        AccTournament.PubSub,
        "new_scores"
      )
    end

    {:ok, socket |> assign(show_container: false, route: :qualifiers)}
  end

  defp attempts_query(map_id) do
    attempts =
      from(a in Attempt,
        distinct: [a.map_id, a.player_id],
        where: a.map_id == type(^map_id, :integer),
        where: not is_nil(a.score),
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score]
      )

    from(a in subquery(attempts),
      order_by: [desc: a.score],
      select: {dense_rank() |> over(partition_by: a.map_id, order_by: [desc: a.score]), a},
      preload: [:player]
    )
  end

  def handle_params(%{"id" => map_id}, _uri, conn) do
    map =
      from(b in BeatMap,
        where: b.id == type(^map_id, :integer),
        preload: [:category]
      )

    qualifier_pool =
      from(b in MapPool,
        where: b.id == ^1,
        preload: [:beat_maps]
      )

    {:ok, %{map: map, attempts: attempts, pool: qualifier_pool}} =
      Ecto.Multi.new()
      |> one(:map, map)
      |> one(:pool, qualifier_pool)
      |> all(:attempts, attempts_query(map_id))
      |> Repo.transaction()

    if(is_nil(map), do: raise(AccTournamentWeb.MapLeaderboardLive.MapNotFound))

    {
      :noreply,
      conn
      |> assign(
        map: map,
        attempts: attempts,
        qualifier_pool: qualifier_pool
      )
    }
  end
end

defmodule AccTournamentWeb.MapLeaderboardLive.MapNotFound do
  defexception message: "No map with such id", plug_status: 404
end
