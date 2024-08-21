defmodule AccTournament.Levels do
  @moduledoc """
  The Levels context.
  """

  import Ecto.Query, warn: false
  alias AccTournament.Repo

  alias AccTournament.Levels.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias AccTournament.Levels.MapPool

  @doc """
  Returns the list of map_pools.

  ## Examples

      iex> list_map_pools()
      [%MapPool{}, ...]

  """
  def list_map_pools do
    Repo.all(MapPool)
  end

  @doc """
  Gets a single map_pool.

  Raises `Ecto.NoResultsError` if the Map pool does not exist.

  ## Examples

      iex> get_map_pool!(123)
      %MapPool{}

      iex> get_map_pool!(456)
      ** (Ecto.NoResultsError)

  """
  def get_map_pool!(id), do: Repo.get!(MapPool, id)

  @doc """
  Creates a map_pool.

  ## Examples

      iex> create_map_pool(%{field: value})
      {:ok, %MapPool{}}

      iex> create_map_pool(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_map_pool(attrs \\ %{}) do
    %MapPool{}
    |> MapPool.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a map_pool.

  ## Examples

      iex> update_map_pool(map_pool, %{field: new_value})
      {:ok, %MapPool{}}

      iex> update_map_pool(map_pool, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_map_pool(%MapPool{} = map_pool, attrs) do
    map_pool
    |> MapPool.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a map_pool.

  ## Examples

      iex> delete_map_pool(map_pool)
      {:ok, %MapPool{}}

      iex> delete_map_pool(map_pool)
      {:error, %Ecto.Changeset{}}

  """
  def delete_map_pool(%MapPool{} = map_pool) do
    Repo.delete(map_pool)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking map_pool changes.

  ## Examples

      iex> change_map_pool(map_pool)
      %Ecto.Changeset{data: %MapPool{}}

  """
  def change_map_pool(%MapPool{} = map_pool, attrs \\ %{}) do
    MapPool.changeset(map_pool, attrs)
  end

  alias AccTournament.Levels.BeatMap

  @doc """
  Returns the list of beat_maps.

  ## Examples

      iex> list_beat_maps()
      [%BeatMap{}, ...]

  """
  def list_beat_maps do
    Repo.all(BeatMap)
  end

  @doc """
  Gets a single beat_map.

  Raises `Ecto.NoResultsError` if the Beat map does not exist.

  ## Examples

      iex> get_beat_map!(123)
      %BeatMap{}

      iex> get_beat_map!(456)
      ** (Ecto.NoResultsError)

  """
  def get_beat_map!(id), do: Repo.get!(BeatMap, id)

  @doc """
  Creates a beat_map.

  ## Examples

      iex> create_beat_map(%{field: value})
      {:ok, %BeatMap{}}

      iex> create_beat_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_beat_map(attrs \\ %{}) do
    %BeatMap{}
    |> BeatMap.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a beat_map.

  ## Examples

      iex> update_beat_map(beat_map, %{field: new_value})
      {:ok, %BeatMap{}}

      iex> update_beat_map(beat_map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_beat_map(%BeatMap{} = beat_map, attrs) do
    beat_map
    |> BeatMap.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a beat_map.

  ## Examples

      iex> delete_beat_map(beat_map)
      {:ok, %BeatMap{}}

      iex> delete_beat_map(beat_map)
      {:error, %Ecto.Changeset{}}

  """
  def delete_beat_map(%BeatMap{} = beat_map) do
    Repo.delete(beat_map)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking beat_map changes.

  ## Examples

      iex> change_beat_map(beat_map)
      %Ecto.Changeset{data: %BeatMap{}}

  """
  def change_beat_map(%BeatMap{} = beat_map, attrs \\ %{}) do
    BeatMap.changeset(beat_map, attrs)
  end
end
