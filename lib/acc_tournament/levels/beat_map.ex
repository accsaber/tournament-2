defmodule AccTournament.Levels.BeatMap do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :name,
             :hash,
             :difficulty,
             :artist,
             :mapper,
             :beatsaver_id,
             :max_score,
             :category_id,
             :map_type
           ]}
  schema "beat_maps" do
    field :name, :string
    field :hash, :string
    field :difficulty, :integer
    field :artist, :string
    field :mapper, :string
    field :beatsaver_id, :string
    field :max_score, :integer
    field :map_type, :string

    belongs_to(:map_pool, AccTournament.Levels.MapPool)
    belongs_to(:category, AccTournament.Levels.Category)
    has_many(:attempts, AccTournament.Qualifiers.Attempt, foreign_key: :map_id)
  end

  def cover_url(%AccTournament.Levels.BeatMap{hash: hash}), do: cover_url(hash)
  def cover_url(hash), do: "https://cdn.beatsaver.com/#{hash |> String.downcase()}.jpg"

  @doc false
  def changeset(beat_map, attrs) do
    beat_map
    |> cast(attrs, [
      :artist,
      :mapper,
      :beatsaver_id,
      :hash,
      :max_score,
      :name,
      :category_id,
      :map_pool_id,
      :difficulty,
      :map_type
    ])
    |> validate_required([
      :artist,
      :mapper,
      :beatsaver_id,
      :hash,
      :max_score,
      :difficulty,
      :map_type
    ])
  end

  def difficulty_string_to_int(difficulty) do
    case difficulty do
      "Easy" -> 1
      "Normal" -> 3
      "Hard" -> 5
      "Expert" -> 7
      "ExpertPlus" -> 9
      _ -> nil
    end
  end

  def difficulty_int_to_string(difficulty) when is_integer(difficulty),
    do: difficulty_int_to_string(difficulty |> Integer.to_string())

  def difficulty_int_to_string(difficulty) when is_binary(difficulty) do
    case difficulty do
      "1" -> "Easy"
      "3" -> "Normal"
      "5" -> "Hard"
      "7" -> "Expert"
      "9" -> "ExpertPlus"
      _ -> nil
    end
  end
end
