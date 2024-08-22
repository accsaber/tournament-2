defmodule AccTournamentWeb.MapPoolsJSON do
  defp diff_name(1), do: "easy"
  defp diff_name(3), do: "normal"
  defp diff_name(5), do: "hard"
  defp diff_name(7), do: "expert"
  defp diff_name(9), do: "expertPlus"
  defp diff_name(id), do: id |> Integer.to_string()

  def playlist(%{pool: pool}) do
    %{
      playlistTitle: "ACC Tournament #{pool.name}",
      playlistAuthor: "Acc Champ Community",
      songs:
        for(
          map <- pool.beat_maps,
          do: %{
            songName: map.name,
            levelAuthorName: map.mapper,
            hash: map.hash |> String.upcase(),
            levelid: "custom_level_#{map.hash |> String.upcase()}",
            customData: %{
              type: map.category.name
            },
            difficulties: [
              %{
                name: diff_name(map.difficulty),
                characteristic: map.map_type
              }
            ]
          }
        )
    }
  end

  def playlist_cat(%{pool: pool, category: category}) do
    %{
      playlistTitle: "ACC Tournament #{pool.name} #{category}",
      playlistAuthor: "Acc Champ Community",
      songs:
        for(
          map <- pool.beat_maps,
          do: %{
            songName: map.name,
            levelAuthorName: map.mapper,
            hash: map.hash |> String.upcase(),
            levelid: "custom_level_#{map.hash |> String.upcase()}",
            customData: %{
              type: map.category.name
            },
            difficulties: [
              %{
                name: diff_name(map.difficulty),
                characteristic: map.map_type
              }
            ]
          }
        )
    }
  end

  def listing(%{pools: pools}) do
    pools
  end

  def listing(%{maps: maps}) do
    maps
  end

  def listing(%{categories: categories}) do
    categories
  end
end
