defmodule AccTournament.Levels.MapPool do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}
  schema "map_pools" do
    field :name, :string
    field :icon_id, :string

    has_many :beat_maps, AccTournament.Levels.BeatMap,
      preload_order: [asc: :category_id, asc: :complexity, asc: :max_score]
  end

  @doc false
  def changeset(map_pools, attrs) do
    map_pools
    |> cast(attrs, [:name, :icon_id])
    |> validate_required([:name, :icon_id])
  end
end
