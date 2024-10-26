defmodule AccTournament.Repo.Migrations.AddStream do
  use Ecto.Migration

  def change do
    create table(:stream) do
      add :current_match_id, references(:matches)
      add :current_round_id, references(:rounds)
      add :current_pick_id, references(:picks)
      add :caster_1_id, references(:users)
      add :caster_2_id, references(:users)
      add :start_time, :naive_datetime
    end

    create index(:stream, [:current_match_id])
    create index(:stream, [:current_round_id])
    create index(:stream, [:current_pick_id])
    create index(:stream, [:caster_1_id])
    create index(:stream, [:caster_2_id])

    alter table(:picks) do
      add :winning_player_id, references(:users)
    end
  end
end
