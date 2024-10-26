defmodule AccTournament.Schedule.Pick do
  use Ecto.Schema
  import Ecto.Changeset

  schema "picks" do
    field :pick_type, Ecto.Enum, values: [:pick, :ban]

    belongs_to :match, AccTournament.Schedule.Match
    belongs_to :map, AccTournament.Levels.BeatMap
    belongs_to :picked_by, AccTournament.Accounts.User
    belongs_to :winning_player, AccTournament.Accounts.User

    field :player_1_score, :integer
    field :player_2_score, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pick, attrs) do
    pick
    |> cast(attrs, [
      :pick_type,
      :picked_by_id,
      :winning_player_id,
      :player_1_score,
      :player_2_score,
      :map_id,
      :match_id
    ])
    |> validate_required([])
  end
end

defmodule AccTournament.Schedule.Pick.Score do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :score, :integer
    field :platform_id, :integer
    field :accuracy, :float
    field :misses, :integer
    field :failed?, :boolean

    has_many :account_bindings, AccTournament.Accounts.Binding,
      foreign_key: :platform_id,
      references: :id
  end

  def changeset(score, attrs) do
    import Ecto.Changeset

    score
    |> cast(attrs, [:player_id, :platform_id, :score, :accuracy, :misses, :failed?])
    |> validate_required([:score, :accuracy, :misses, :failed?])
  end
end
