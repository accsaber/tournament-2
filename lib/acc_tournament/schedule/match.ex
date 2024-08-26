defmodule AccTournament.Schedule.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :scheduled_at, :utc_datetime

    belongs_to :player_1, AccTournament.Accounts.User
    belongs_to :player_2, AccTournament.Accounts.User
    belongs_to :winner, AccTournament.Accounts.User
    belongs_to :round, AccTournament.Schedule.Round

    has_many :picks, AccTournament.Schedule.Pick

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:scheduled_at])
    |> validate_required([:scheduled_at])
  end
end
