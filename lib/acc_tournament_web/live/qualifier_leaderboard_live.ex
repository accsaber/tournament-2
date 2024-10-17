defmodule AccTournamentWeb.QualifierLeaderboardLive do
  alias AccTournament.Accounts.User
  alias AccTournament.Levels.MapPool
  alias AccTournament.Repo
  alias AccTournament.Levels.BeatMap
  use AccTournamentWeb, :live_view

  def qualifier_header(assigns) do
    ~H"""
    <h1 class="relative max-w-screen-lg mx-auto text-4xl p-2 px-3 mt-8">Qualifiers</h1>
    <div class="flex items-center relative max-w-screen-lg mx-auto p-2 gap-1 mb-2">
      <.link
        navigate={~p"/qualifiers"}
        class={
          [
            "rounded p-1.5 flex gap-1",
            if(@current_route == {:leaderboard, :players},
              do: "bg-black/10 dark:bg-white/20",
              else: "hover:bg-black/5 dark:hover:bg-white/10"
            )
          ]
          |> Enum.join(" ")
        }
      >
        <.icon name="hero-globe-alt" class="w-7 h-7 m-0.5 rounded-sm" />
      </.link>

      <.link
        :for={map <- @qualifier_pool.beat_maps}
        navigate={~p"/qualifiers/map_leaderboard/#{map.id}"}
        class={
          [
            "rounded p-1.5",
            if(@current_route == {:map, map.id},
              do: "bg-black/10 dark:bg-white/20",
              else: "hover:bg-black/5 dark:hover:bg-white/10"
            )
          ]
          |> Enum.join(" ")
        }
      >
        <img src={BeatMap.cover_url(map)} class="w-8 aspect-square rounded-sm bg-white/20" />
      </.link>
      <.link
        href={~p"/api/map_pools/1/playlist"}
        class="ml-auto flex items-center hover:bg-black/5 dark:hover:bg-white/10 p-1.5 sm:px-3 rounded gap-2"
        download="acc-qualifiers.bplist"
      >
        <.icon name="hero-arrow-down-tray" class="w-5 h-5" />
        <div class="hidden sm:block">Download playlist</div>
      </.link>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div
      :if={length(@players) > 0}
      class="dots-container absolute inset-0 overflow-hidden -top-8 h-96"
    >
      <div class="absolute -inset-6 bottom-0 blur-[1.5rem]">
        <img
          class="object-cover w-full h-full saturate-150"
          src={User.public_avatar_url(@players |> List.first() |> elem(1))}
        />
      </div>
      <div class="dots" />
    </div>
    <.qualifier_header qualifier_pool={@qualifier_pool} current_route={{:leaderboard, :players}} />
    <div :if={length(@players) > 0} class="card max-w-screen-lg mx-auto relative">
      <.table rows={@players} id="players">
        <:col :let={{rank, _player}} label="#">
          <%= rank %>
        </:col>
        <:col :let={{_rank, player}} label="Player">
          <.link
            navigate={"#{player}"}
            class="flex gap-2 items-center relative font-semibold underline"
          >
            <img src={User.public_avatar_url(player)} class="h-6 w-6 rounded-full absolute" />
            <div class="w-full ml-8">
              <%= player.display_name %>
            </div>
          </.link>
        </:col>
        <:col :let={{_rank, player}} label="Average AP">
          <%= if(!is_nil(player.average_weight),
            do: player.average_weight |> :erlang.float_to_binary(decimals: 2)
          ) %>
        </:col>
        <:action :let={{_rank, player}}>
          <.link navigate={"#{player}"} class="text-sm font-semibold">
            Profile
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  def mount(_, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        AccTournament.PubSub,
        "players_reranked"
      )
    end

    {:ok, socket |> assign(show_container: false, route: :qualifiers)}
  end

  def handle_info(:players_reranked, socket) do
    players = query_players() |> Repo.all()
    {:noreply, socket |> assign(players: players)}
  end

  defp query_players() do
    import Ecto.Query, only: [from: 2]

    from(c in User,
      where: c.average_weight > 0.0,
      order_by: [desc: c.average_weight],
      select: {dense_rank() |> over(order_by: [desc: c.average_weight]), c}
    )
  end

  def handle_params(_unsigned_params, _uri, socket) do
    import Ecto.Query, only: [from: 2]

    {:ok, %{pool: qualifier_pool, players: players}} =
      Ecto.Multi.new()
      |> Ecto.Multi.one(
        :pool,
        from(b in MapPool,
          where: b.id == ^1,
          preload: [:beat_maps]
        )
      )
      |> Ecto.Multi.all(
        :players,
        query_players()
      )
      |> Repo.transaction()

    {:noreply,
     socket
     |> assign(
       qualifier_pool: qualifier_pool,
       players: players,
       page_title: "Qualifier Leaderboard"
     )}
  end
end
