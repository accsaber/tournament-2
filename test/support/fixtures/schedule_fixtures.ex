defmodule AccTournament.ScheduleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccTournament.Schedule` context.
  """

  @doc """
  Generate a round.
  """
  def round_fixture(attrs \\ %{}) do
    {:ok, round} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> AccTournament.Schedule.create_round()

    round
  end

  @doc """
  Generate a match.
  """
  def match_fixture(attrs \\ %{}) do
    {:ok, match} =
      attrs
      |> Enum.into(%{
        scheduled_at: ~U[2024-08-25 08:07:00Z]
      })
      |> AccTournament.Schedule.create_match()

    match
  end

  @doc """
  Generate a pick.
  """
  def pick_fixture(attrs \\ %{}) do
    {:ok, pick} =
      attrs
      |> Enum.into(%{
        pick_type: "some pick_type"
      })
      |> AccTournament.Schedule.create_pick()

    pick
  end
end
