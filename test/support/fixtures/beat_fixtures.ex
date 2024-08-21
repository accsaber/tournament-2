defmodule AccTournament.BeatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccTournament.Beat` context.
  """

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
      |> AccTournament.Beat.create_beat_map()

    beat_map
  end
end
