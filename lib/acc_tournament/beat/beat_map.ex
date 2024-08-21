defmodule AccTournament.Beat.BeatMap do
  use Ecto.Schema
  import Ecto.Changeset

  schema "beat_maps" do
    field :name, :string
    field :hash, :string
    field :artist, :string
    field :mapper, :string
    field :beatsaver_id, :string
    field :difficulty, :integer
    field :max_score, :integer
    field :category_id, :id
    field :map_pool_id, :id
  end

  @doc false
  def changeset(beat_map, attrs) do
    beat_map
    |> cast(attrs, [:name, :artist, :mapper, :beatsaver_id, :hash, :difficulty, :max_score])
    |> validate_required([:name, :artist, :mapper, :beatsaver_id, :hash, :difficulty, :max_score])
  end
end
