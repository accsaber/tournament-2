defmodule AccTournament.ScheduleTest do
  use AccTournament.DataCase

  alias AccTournament.Schedule

  describe "rounds" do
    alias AccTournament.Schedule.Round

    import AccTournament.ScheduleFixtures

    @invalid_attrs %{name: nil}

    test "list_rounds/0 returns all rounds" do
      round = round_fixture()
      assert Schedule.list_rounds() == [round]
    end

    test "get_round!/1 returns the round with given id" do
      round = round_fixture()
      assert Schedule.get_round!(round.id) == round
    end

    test "create_round/1 with valid data creates a round" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Round{} = round} = Schedule.create_round(valid_attrs)
      assert round.name == "some name"
    end

    test "create_round/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schedule.create_round(@invalid_attrs)
    end

    test "update_round/2 with valid data updates the round" do
      round = round_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Round{} = round} = Schedule.update_round(round, update_attrs)
      assert round.name == "some updated name"
    end

    test "update_round/2 with invalid data returns error changeset" do
      round = round_fixture()
      assert {:error, %Ecto.Changeset{}} = Schedule.update_round(round, @invalid_attrs)
      assert round == Schedule.get_round!(round.id)
    end

    test "delete_round/1 deletes the round" do
      round = round_fixture()
      assert {:ok, %Round{}} = Schedule.delete_round(round)
      assert_raise Ecto.NoResultsError, fn -> Schedule.get_round!(round.id) end
    end

    test "change_round/1 returns a round changeset" do
      round = round_fixture()
      assert %Ecto.Changeset{} = Schedule.change_round(round)
    end
  end

  describe "matches" do
    alias AccTournament.Schedule.Match

    import AccTournament.ScheduleFixtures

    @invalid_attrs %{scheduled_at: nil}

    test "list_matches/0 returns all matches" do
      match = match_fixture()
      assert Schedule.list_matches() == [match]
    end

    test "get_match!/1 returns the match with given id" do
      match = match_fixture()
      assert Schedule.get_match!(match.id) == match
    end

    test "create_match/1 with valid data creates a match" do
      valid_attrs = %{scheduled_at: ~U[2024-08-25 08:07:00Z]}

      assert {:ok, %Match{} = match} = Schedule.create_match(valid_attrs)
      assert match.scheduled_at == ~U[2024-08-25 08:07:00Z]
    end

    test "create_match/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schedule.create_match(@invalid_attrs)
    end

    test "update_match/2 with valid data updates the match" do
      match = match_fixture()
      update_attrs = %{scheduled_at: ~U[2024-08-26 08:07:00Z]}

      assert {:ok, %Match{} = match} = Schedule.update_match(match, update_attrs)
      assert match.scheduled_at == ~U[2024-08-26 08:07:00Z]
    end

    test "update_match/2 with invalid data returns error changeset" do
      match = match_fixture()
      assert {:error, %Ecto.Changeset{}} = Schedule.update_match(match, @invalid_attrs)
      assert match == Schedule.get_match!(match.id)
    end

    test "delete_match/1 deletes the match" do
      match = match_fixture()
      assert {:ok, %Match{}} = Schedule.delete_match(match)
      assert_raise Ecto.NoResultsError, fn -> Schedule.get_match!(match.id) end
    end

    test "change_match/1 returns a match changeset" do
      match = match_fixture()
      assert %Ecto.Changeset{} = Schedule.change_match(match)
    end
  end

  describe "picks" do
    alias AccTournament.Schedule.Pick

    import AccTournament.ScheduleFixtures

    @invalid_attrs %{pick_type: nil}

    test "list_picks/0 returns all picks" do
      pick = pick_fixture()
      assert Schedule.list_picks() == [pick]
    end

    test "get_pick!/1 returns the pick with given id" do
      pick = pick_fixture()
      assert Schedule.get_pick!(pick.id) == pick
    end

    test "create_pick/1 with valid data creates a pick" do
      valid_attrs = %{pick_type: "some pick_type"}

      assert {:ok, %Pick{} = pick} = Schedule.create_pick(valid_attrs)
      assert pick.pick_type == "some pick_type"
    end

    test "create_pick/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schedule.create_pick(@invalid_attrs)
    end

    test "update_pick/2 with valid data updates the pick" do
      pick = pick_fixture()
      update_attrs = %{pick_type: "some updated pick_type"}

      assert {:ok, %Pick{} = pick} = Schedule.update_pick(pick, update_attrs)
      assert pick.pick_type == "some updated pick_type"
    end

    test "update_pick/2 with invalid data returns error changeset" do
      pick = pick_fixture()
      assert {:error, %Ecto.Changeset{}} = Schedule.update_pick(pick, @invalid_attrs)
      assert pick == Schedule.get_pick!(pick.id)
    end

    test "delete_pick/1 deletes the pick" do
      pick = pick_fixture()
      assert {:ok, %Pick{}} = Schedule.delete_pick(pick)
      assert_raise Ecto.NoResultsError, fn -> Schedule.get_pick!(pick.id) end
    end

    test "change_pick/1 returns a pick changeset" do
      pick = pick_fixture()
      assert %Ecto.Changeset{} = Schedule.change_pick(pick)
    end
  end
end
