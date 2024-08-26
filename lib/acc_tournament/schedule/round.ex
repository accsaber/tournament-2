defmodule AccTournament.Schedule.Round do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rounds" do
    field :name, :string

    belongs_to :map_pool, AccTournament.Levels.MapPool
    has_many :matches, AccTournament.Schedule.Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
