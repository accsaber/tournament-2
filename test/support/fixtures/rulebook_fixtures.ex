defmodule AccTournament.RulebookFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AccTournament.Rulebook` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        body: "some body",
        slug: "some slug",
        title: "some title"
      })
      |> AccTournament.Rulebook.create_page()

    page
  end
end
