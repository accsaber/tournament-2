defmodule AccTournament.BeatTest do
  use AccTournament.DataCase

  alias AccTournament.Beat

  describe "beat_maps" do
    alias AccTournament.Beat.BeatMap

    import AccTournament.BeatFixtures

    @invalid_attrs %{name: nil, hash: nil, artist: nil, mapper: nil, beatsaver_id: nil, difficulty: nil, max_score: nil}

    test "list_beat_maps/0 returns all beat_maps" do
      beat_map = beat_map_fixture()
      assert Beat.list_beat_maps() == [beat_map]
    end

    test "get_beat_map!/1 returns the beat_map with given id" do
      beat_map = beat_map_fixture()
      assert Beat.get_beat_map!(beat_map.id) == beat_map
    end

    test "create_beat_map/1 with valid data creates a beat_map" do
      valid_attrs = %{name: "some name", hash: "some hash", artist: "some artist", mapper: "some mapper", beatsaver_id: "some beatsaver_id", difficulty: "some difficulty", max_score: 42}

      assert {:ok, %BeatMap{} = beat_map} = Beat.create_beat_map(valid_attrs)
      assert beat_map.name == "some name"
      assert beat_map.hash == "some hash"
      assert beat_map.artist == "some artist"
      assert beat_map.mapper == "some mapper"
      assert beat_map.beatsaver_id == "some beatsaver_id"
      assert beat_map.difficulty == "some difficulty"
      assert beat_map.max_score == 42
    end

    test "create_beat_map/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Beat.create_beat_map(@invalid_attrs)
    end

    test "update_beat_map/2 with valid data updates the beat_map" do
      beat_map = beat_map_fixture()
      update_attrs = %{name: "some updated name", hash: "some updated hash", artist: "some updated artist", mapper: "some updated mapper", beatsaver_id: "some updated beatsaver_id", difficulty: "some updated difficulty", max_score: 43}

      assert {:ok, %BeatMap{} = beat_map} = Beat.update_beat_map(beat_map, update_attrs)
      assert beat_map.name == "some updated name"
      assert beat_map.hash == "some updated hash"
      assert beat_map.artist == "some updated artist"
      assert beat_map.mapper == "some updated mapper"
      assert beat_map.beatsaver_id == "some updated beatsaver_id"
      assert beat_map.difficulty == "some updated difficulty"
      assert beat_map.max_score == 43
    end

    test "update_beat_map/2 with invalid data returns error changeset" do
      beat_map = beat_map_fixture()
      assert {:error, %Ecto.Changeset{}} = Beat.update_beat_map(beat_map, @invalid_attrs)
      assert beat_map == Beat.get_beat_map!(beat_map.id)
    end

    test "delete_beat_map/1 deletes the beat_map" do
      beat_map = beat_map_fixture()
      assert {:ok, %BeatMap{}} = Beat.delete_beat_map(beat_map)
      assert_raise Ecto.NoResultsError, fn -> Beat.get_beat_map!(beat_map.id) end
    end

    test "change_beat_map/1 returns a beat_map changeset" do
      beat_map = beat_map_fixture()
      assert %Ecto.Changeset{} = Beat.change_beat_map(beat_map)
    end
  end
end
