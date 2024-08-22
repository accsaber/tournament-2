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

  def render(assigns) do
    ~H"""
    <img
      src={BeatMap.cover_url(@map)}
      class="absolute -top-8 left-0 w-full h-80 pointer-events-none object-cover gradient-transparent blur-xl opacity-70"
    />
    <.qualifier_header qualifier_pool={@qualifier_pool} current_route={{:map, @map.id}} />
    <div class="flex items-center gap-4 card relative max-w-screen-lg mx-auto  shadow-xl">
      <img src={BeatMap.cover_url(@map)} class="rounded-xl w-32 aspect-square" />
      <div class="flex flex-col gap-0.5">
        <div class="text-3xl font-semibold"><%= @map.name %></div>
        <div><%= @map.artist %></div>
        <div>Mapped by <strong class="font-semibold"><%= @map.mapper %></strong></div>
        <div class="flex gap-0.5">
          <div class="select-all px-2 h-8 flex items-center bg-neutral-100 dark:bg-neutral-900 rounded w-fit font-mono">
            !bsr <%= @map.beatsaver_id %>
          </div>
          <a
            href={"https://beatsaver.com/maps/#{@map.beatsaver_id}"}
            class={[
              "flex items-center justify-center",
              "bg-neutral-100 hover:bg-neutral-200 dark:bg-neutral-900 dark:hover:bg-neutral-700 rounded w-8 h-8"
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
            navigate={~p"/profile/#{attempt.player.slug}"}
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
        <:action :let={{_rank, attempt}}>
          <.link navigate={~p"/profile/#{attempt.player.slug}"} class="text-sm font-semibold">
            Profile
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket |> assign(show_container: false, route: :qualifiers)}
  end

  def handle_params(%{"id" => map_id}, _uri, conn) do
    attempts =
      from(a in Attempt,
        distinct: [a.map_id, a.player_id],
        where: a.map_id == type(^map_id, :integer),
        where: not is_nil(a.score),
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score]
      )

    attempts =
      from(a in subquery(attempts),
        order_by: [desc: a.score],
        select: {dense_rank() |> over(partition_by: a.map_id, order_by: [desc: a.score]), a},
        preload: [:player]
      )

    map =
      from(b in BeatMap,
        where: b.id == type(^map_id, :integer)
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
      |> all(:attempts, attempts)
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
