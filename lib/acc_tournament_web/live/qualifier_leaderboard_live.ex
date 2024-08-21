defmodule AccTournamentWeb.QualifierLeaderboardLive do
  alias AccTournament.Accounts.User
  alias AccTournament.Levels.MapPool
  alias AccTournament.Repo
  alias AccTournament.Levels.BeatMap
  use AccTournamentWeb, :live_view

  def qualifier_header(assigns) do
    ~H"""
    <h1 class="relative max-w-screen-lg mx-auto text-4xl p-2 px-3 mt-8">Qualifiers</h1>
    <div class="flex relative max-w-screen-lg mx-auto p-2 gap-1 mb-2">
      <.link
        patch={~p"/qualifiers"}
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
        patch={~p"/qualifiers/map_leaderboard/#{map.id}"}
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
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <picture>
      <source
        type="image/jxl"
        srcset={"#{~p"/images/shiny/shiny@720x1280.jxl"} 720w, #{~p"/images/shiny/shiny@1080x1920.jxl"} 1080w, #{~p"/images/shiny/shiny@1920x1080.jxl"} 1920w, #{~p"/images/shiny/shiny@2560x1440.jxl"} 2560w, #{~p"/images/shiny/shiny@3840x2160.jxl"} 3840w"}
      />
      <source
        type="image/avif"
        srcset={"#{~p"/images/shiny/shiny@720x1280.avif"} 720w, #{~p"/images/shiny/shiny@1080x1920.avif"} 1080w, #{~p"/images/shiny/shiny@1920x1080.avif"} 1920w, #{~p"/images/shiny/shiny@2560x1440.avif"} 2560w, #{~p"/images/shiny/shiny@3840x2160.avif"} 3840w"}
      />
      <source
        type="image/webp"
        srcset={"#{~p"/images/shiny/shiny@720x1280.webp"} 720w, #{~p"/images/shiny/shiny@1080x1920.webp"} 1080w, #{~p"/images/shiny/shiny@1920x1080.webp"} 1920w, #{~p"/images/shiny/shiny@2560x1440.webp"} 2560w, #{~p"/images/shiny/shiny@3840x2160.webp"} 3840w"}
      />
      <source
        type="image/jpg"
        srcset={"#{~p"/images/shiny/shiny@720x1280.jpg"} 720w, #{~p"/images/shiny/shiny@1080x1920.jpg"} 1080w, #{~p"/images/shiny/shiny@1920x1080.jpg"} 1920w, #{~p"/images/shiny/shiny@2560x1440.jpg"} 2560w, #{~p"/images/shiny/shiny@3840x2160.jpg"} 3840w"}
      />

      <img
        src={~p"/images/shiny/shiny@1920x1080.jpg"}
        alt=""
        id="waves-fallback"
        class="absolute top-0 left-0 w-full h-80 pointer-events-none object-cover gradient-transparent blur-xl"
      />
    </picture>
    <.qualifier_header qualifier_pool={@qualifier_pool} current_route={{:leaderboard, :players}} />
    <div class="card max-w-screen-lg mx-auto relative prose dark:prose-invert">
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th colspan="2">Player</th>
            <th class="text-right whitespace-nowrap">Average weight</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{rank, player} <- @players}>
            <td><%= rank %></td>
            <td class="not-prose">
              <img src={User.public_avatar_url(player)} class="h-6 w-6 rounded-full -my-2" />
            </td>
            <td class="w-full"><%= player.display_name %></td>

            <td :if={player.average_weight} class="text-right tabular-nums">
              <%= player.average_weight |> :erlang.float_to_binary(decimals: 2) %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket |> assign(show_container: false)}
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
        from(c in User,
          where: c.average_weight < 25.0,
          order_by: [asc: c.average_weight],
          select: {dense_rank() |> over(order_by: [asc: c.average_weight]), c}
        )
      )
      |> Repo.transaction()

    {:noreply,
     socket
     |> assign(qualifier_pool: qualifier_pool, players: players)}
  end
end