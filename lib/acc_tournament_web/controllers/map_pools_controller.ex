defmodule AccTournamentWeb.MapPoolsController do
  alias AccTournament.Levels.Category
  alias AccTournament.Levels.MapPool
  alias AccTournament.Repo
  use AccTournamentWeb, :controller

  def map_listing(conn, %{"id" => id}) do
    import Ecto.Query, only: [where: 2, preload: 2]
    pool = MapPool |> where(id: ^id) |> preload(beat_maps: :category) |> Repo.one()
    categories = Category |> Repo.all()

    conn
    |> render(:listing,
      maps: pool.beat_maps,
      pool: pool,
      categories: categories,
      route: :map_pools
    )
  end

  def playlist(conn, %{"id" => id}) do
    import Ecto.Query, only: [where: 2, preload: 2]
    pool = MapPool |> where(id: ^id) |> preload(beat_maps: :category) |> Repo.one()

    conn |> render(:playlist, pool: pool)
  end

  def cat_playlist(conn, %{"id" => id, "category" => category}) do
    import Ecto.Query, only: [where: 2, preload: 2]
    pool = MapPool |> where(id: ^id) |> preload(beat_maps: :category) |> Repo.one()
    pool = %{pool | beat_maps: Enum.filter(pool.beat_maps, &(&1.category.name == category))}
    conn |> render(:playlist_cat, pool: pool, category: category, route: :map_pools)
  end

  @spec pool_listing(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def pool_listing(conn, _args) do
    import Ecto.Query, only: [preload: 2]

    pools =
      MapPool
      |> preload(:beat_maps)
      |> Repo.all()

    conn
    |> render(:listing, pools: pools, route: :map_pools)
  end

  def category_listing(conn, _args) do
    categories = Category |> Repo.all()
    conn |> render(:listing, categories: categories, route: :map_pools)
  end
end
