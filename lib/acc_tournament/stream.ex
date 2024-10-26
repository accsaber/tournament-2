defmodule AccTournament.Stream do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id]}
  schema "stream" do
    field :start_time, :naive_datetime
    belongs_to :current_match, AccTournament.Schedule.Match
    belongs_to :current_round, AccTournament.Schedule.Round
    belongs_to :current_pick, AccTournament.Schedule.Pick
    belongs_to :caster_1, AccTournament.Accounts.User
    belongs_to :caster_2, AccTournament.Accounts.User
  end

  @doc false
  def changeset(stream, attrs) do
    stream
    |> cast(attrs, [:current_pick_id, :current_match_id, :current_round_id])
    |> IO.inspect()
  end
end
