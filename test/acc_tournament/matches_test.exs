defmodule AccTournament.MatchesTest do
  use AccTournament.DataCase

  alias AccTournament.Matches

  describe "matches" do
    alias AccTournament.Matches.Match

    import AccTournament.MatchesFixtures

    @invalid_attrs %{scheduled_time: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Matches.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Matches.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{scheduled_time: ~N[2024-10-21 19:57:00]}

      assert {:ok, %Match{} = match} = Matches.create_match(valid_attrs)
      assert match.scheduled_time == ~N[2024-10-21 19:57:00]
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{scheduled_time: ~N[2024-10-22 19:57:00]}

      assert {:ok, %Match{} = match} = Matches.update_match(match, update_attrs)
      assert match.scheduled_time == ~N[2024-10-22 19:57:00]
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_match(match, @invalid_attrs)
      assert match == Matches.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Matches.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Matches.change_match(match)
    end
  end

  describe "picks" do
    alias AccTournament.Matches.Pick

    import AccTournament.MatchesFixtures

    @invalid_attrs %{scores: nil}

    test "list_picks/0 returns all picks" do
      pick = pick_fixture()
      assert Matches.list_picks() == [pick]
    end

    test "get_pick!/1 returns the pick with given id" do
      pick = pick_fixture()
      assert Matches.get_pick!(pick.id) == pick
    end

    test "create_pick/1 with valid data creates a pick" do
      valid_attrs = %{scores: %{}}

      assert {:ok, %Pick{} = pick} = Matches.create_pick(valid_attrs)
      assert pick.scores == %{}
    end

    test "create_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Matches.create_pick(@invalid_attrs)
    end

    test "update_pick/2 with valid data updates the pick" do
      pick = pick_fixture()
      update_attrs = %{scores: %{}}

      assert {:ok, %Pick{} = pick} = Matches.update_pick(pick, update_attrs)
      assert pick.scores == %{}
    end

    test "update_pick/2 with invalid data returns error changeset" do
      pick = pick_fixture()
      assert {:error, %Ecto.Changeset{}} = Matches.update_pick(pick, @invalid_attrs)
      assert pick == Matches.get_pick!(pick.id)
    end

    test "delete_pick/1 deletes the pick" do
      pick = pick_fixture()
      assert {:ok, %Pick{}} = Matches.delete_pick(pick)
      assert_raise Ecto.NoResultsError, fn -> Matches.get_pick!(pick.id) end
    end

    test "change_pick/1 returns a pick changeset" do
      pick = pick_fixture()
      assert %Ecto.Changeset{} = Matches.change_pick(pick)
    end
  end
end
