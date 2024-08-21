defmodule AccTournament.Repo.Migrations.CreateAttempts do
  use Ecto.Migration

  def change do
    create table(:attempts) do
      add :score, :integer
      add :map_id, references(:beat_maps, on_delete: :nothing)
      add :player_id, references(:users, on_delete: :nothing)
      add :weight, :float

      timestamps()
    end

    create index(:attempts, [:map_id])
    create index(:attempts, [:player_id])

    alter table("users") do
      add :average_weight, :float
    end
  end
end
