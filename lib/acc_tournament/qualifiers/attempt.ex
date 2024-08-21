defmodule AccTournament.Qualifiers.Attempt do
  alias AccTournament.Accounts
  alias AccTournament.Levels.BeatMap
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :score, :player_id, :map_id, :inserted_at, :updated_at]}
  schema "attempts" do
    field :score, :integer
    field :weight, :float

    belongs_to :map, BeatMap
    belongs_to :player, Accounts.User

    timestamps()
  end

  @doc false
  def score_changeset(attempt, attrs) do
    attempt
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end

  def weight_changeset(attempt, attrs) do
    attempt
    |> cast(attrs, [:weight])
  end
end
