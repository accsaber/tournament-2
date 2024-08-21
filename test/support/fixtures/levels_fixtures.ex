defmodule AccTournament.LevelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccTournament.Levels` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> AccTournament.Levels.create_category()

    category
  end

  @doc """
  Generate a map_pool.
  """
  def map_pool_fixture(attrs \\ %{}) do
    {:ok, map_pool} =
      attrs
      |> Enum.into(%{
        icon_id: "some icon_id",
        name: "some name"
      })
      |> AccTournament.Levels.create_map_pool()

    map_pool
  end

  @doc """
  Generate a beat_map.
  """
  def beat_map_fixture(attrs \\ %{}) do
    {:ok, beat_map} =
      attrs
      |> Enum.into(%{
        artist: "some artist",
        beatsaver_id: "some beatsaver_id",
        difficulty: "some difficulty",
        hash: "some hash",
        mapper: "some mapper",
        max_score: 42,
        name: "some name"
      })
      |> AccTournament.Levels.create_beat_map()

    beat_map
  end
end
