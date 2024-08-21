defmodule AccTournament.LevelsTest do
  use AccTournament.DataCase

  alias AccTournament.Levels

  describe "categories" do
    alias AccTournament.Levels.Category

    import AccTournament.LevelsFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Levels.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Levels.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Levels.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Levels.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Levels.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Levels.update_category(category, @invalid_attrs)
      assert category == Levels.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Levels.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Levels.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Levels.change_category(category)
    end
  end

  describe "map_pools" do
    alias AccTournament.Levels.MapPool

    import AccTournament.LevelsFixtures

    @invalid_attrs %{name: nil, icon_id: nil}

    test "list_map_pools/0 returns all map_pools" do
      map_pool = map_pool_fixture()
      assert Levels.list_map_pools() == [map_pool]
    end

    test "get_map_pool!/1 returns the map_pool with given id" do
      map_pool = map_pool_fixture()
      assert Levels.get_map_pool!(map_pool.id) == map_pool
    end

    test "create_map_pool/1 with valid data creates a map_pool" do
      valid_attrs = %{name: "some name", icon_id: "some icon_id"}

      assert {:ok, %MapPool{} = map_pool} = Levels.create_map_pool(valid_attrs)
      assert map_pool.name == "some name"
      assert map_pool.icon_id == "some icon_id"
    end

    test "create_map_pool/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Levels.create_map_pool(@invalid_attrs)
    end

    test "update_map_pool/2 with valid data updates the map_pool" do
      map_pool = map_pool_fixture()
      update_attrs = %{name: "some updated name", icon_id: "some updated icon_id"}

      assert {:ok, %MapPool{} = map_pool} = Levels.update_map_pool(map_pool, update_attrs)
      assert map_pool.name == "some updated name"
      assert map_pool.icon_id == "some updated icon_id"
    end

    test "update_map_pool/2 with invalid data returns error changeset" do
      map_pool = map_pool_fixture()
      assert {:error, %Ecto.Changeset{}} = Levels.update_map_pool(map_pool, @invalid_attrs)
      assert map_pool == Levels.get_map_pool!(map_pool.id)
    end

    test "delete_map_pool/1 deletes the map_pool" do
      map_pool = map_pool_fixture()
      assert {:ok, %MapPool{}} = Levels.delete_map_pool(map_pool)
      assert_raise Ecto.NoResultsError, fn -> Levels.get_map_pool!(map_pool.id) end
    end

    test "change_map_pool/1 returns a map_pool changeset" do
      map_pool = map_pool_fixture()
      assert %Ecto.Changeset{} = Levels.change_map_pool(map_pool)
    end
  end

  describe "beat_maps" do
    alias AccTournament.Levels.BeatMap

    import AccTournament.LevelsFixtures

    @invalid_attrs %{name: nil, hash: nil, artist: nil, mapper: nil, beatsaver_id: nil, difficulty: nil, max_score: nil}

    test "list_beat_maps/0 returns all beat_maps" do
      beat_map = beat_map_fixture()
      assert Levels.list_beat_maps() == [beat_map]
    end

    test "get_beat_map!/1 returns the beat_map with given id" do
      beat_map = beat_map_fixture()
      assert Levels.get_beat_map!(beat_map.id) == beat_map
    end

    test "create_beat_map/1 with valid data creates a beat_map" do
      valid_attrs = %{name: "some name", hash: "some hash", artist: "some artist", mapper: "some mapper", beatsaver_id: "some beatsaver_id", difficulty: "some difficulty", max_score: 42}

      assert {:ok, %BeatMap{} = beat_map} = Levels.create_beat_map(valid_attrs)
      assert beat_map.name == "some name"
      assert beat_map.hash == "some hash"
      assert beat_map.artist == "some artist"
      assert beat_map.mapper == "some mapper"
      assert beat_map.beatsaver_id == "some beatsaver_id"
      assert beat_map.difficulty == "some difficulty"
      assert beat_map.max_score == 42
    end

    test "create_beat_map/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Levels.create_beat_map(@invalid_attrs)
    end

    test "update_beat_map/2 with valid data updates the beat_map" do
      beat_map = beat_map_fixture()
      update_attrs = %{name: "some updated name", hash: "some updated hash", artist: "some updated artist", mapper: "some updated mapper", beatsaver_id: "some updated beatsaver_id", difficulty: "some updated difficulty", max_score: 43}

      assert {:ok, %BeatMap{} = beat_map} = Levels.update_beat_map(beat_map, update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Levels.update_beat_map(beat_map, @invalid_attrs)
      assert beat_map == Levels.get_beat_map!(beat_map.id)
    end

    test "delete_beat_map/1 deletes the beat_map" do
      beat_map = beat_map_fixture()
      assert {:ok, %BeatMap{}} = Levels.delete_beat_map(beat_map)
      assert_raise Ecto.NoResultsError, fn -> Levels.get_beat_map!(beat_map.id) end
    end

    test "change_beat_map/1 returns a beat_map changeset" do
      beat_map = beat_map_fixture()
      assert %Ecto.Changeset{} = Levels.change_beat_map(beat_map)
    end
  end
end
