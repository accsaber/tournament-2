defmodule AccTournament.MatchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccTournament.Matches` context.
  """

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{
        scheduled_time: ~N[2024-10-21 19:57:00]
      })
      |> AccTournament.Matches.create_match()

    match
  end

  @doc """
  Generate a pick.
  """
  def pick_fixture(attrs \\ %{}) do
    {:ok, pick} =
      attrs
      |> Enum.into(%{
        scores: %{}
      })
      |> AccTournament.Matches.create_pick()

    pick
  end
end
