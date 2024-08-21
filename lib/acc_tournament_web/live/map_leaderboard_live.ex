defmodule AccTournamentWeb.MapLeaderboardLive do
  alias AccTournament.Levels.MapPool
  alias AccTournament.Qualifiers.Attempt
  alias AccTournament.Levels.BeatMap
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
      <div class="flex flex-col">
        <div class="text-3xl font-semibold"><%= @map.name %></div>
        <div><%= @map.artist %></div>
        <div>Mapped by <%= @map.mapper %></div>
        <div class="select-all p-0.5 px-1 bg-padding-bg rounded w-fit font-mono">
          !bsr <%= @map.beatsaver_id %>
        </div>
      </div>
    </div>
    <div class="prose dark:prose-invert  relative max-w-screen-lg mx-auto p-6">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th colspan="2">Player</th>
            <th>Score</th>
            <th class="text-right">Accuracy</th>
            <th class="text-right">Weight</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{rank, attempt} <- @attempts}>
            <td><%= rank %></td>
            <td>
              <.link navigate={~p"/profile/#{attempt.player.slug}"}>
                <%= attempt.player.display_name %>
              </.link>
            </td>
            <td><%= attempt.score %></td>
            <td class="tabular-nums text-right">
              <%= (attempt.score / @map.max_score * 100) |> :erlang.float_to_binary(decimals: 2) %>%
            </td>
            <td :if={attempt.weight} class="text-right tabular-nums">
              <%= attempt.weight |> :erlang.float_to_binary(decimals: 2) %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
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
        preload: [player: [:country]]
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
        show_container: false,
        qualifier_pool: qualifier_pool
      )
    }
  end
end

defmodule AccTournamentWeb.MapLeaderboardLive.MapNotFound do
  defexception message: "No map with such id", plug_status: 404
end
