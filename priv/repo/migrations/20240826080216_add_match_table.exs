defmodule AccTournament.Repo.Migrations.AddMatchTable do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :name, :text
      add :map_pool_id, references(:map_pools)

      timestamps()
    end

    create index(:rounds, [:map_pool_id])

    create table(:matches) do
      add :scheduled_at, :utc_datetime
      add :player_1_id, references(:users, on_delete: :nothing)
      add :player_2_id, references(:users, on_delete: :nothing)
      add :winner_id, references(:users, on_delete: :nothing)
      add :round_id, references(:rounds, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:matches, [:player_1_id])
    create index(:matches, [:player_2_id])
    create index(:matches, [:winner_id])
    create index(:matches, [:round_id])

    execute "CREATE TYPE pick_type AS ENUM ('pick', 'ban');",
            "DROP TYPE pick_type;"

    create table(:picks) do
      add :pick_type, :pick_type
      add :match_id, references(:matches, on_delete: :nothing)
      add :map_id, references(:beat_maps, on_delete: :nothing)
      add :picked_by_id, references(:users, on_delete: :nothing)

      add :player_1_score, :bigint
      add :player_2_score, :bigint

      timestamps(type: :utc_datetime)
    end

    create index(:picks, [:match_id])
    create index(:picks, [:map_id])
    create index(:picks, [:picked_by_id])
  end
end
