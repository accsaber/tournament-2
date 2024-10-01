defmodule AccTournament.Repo.Migrations.AddBeatMapComplexity do
  use Ecto.Migration

  def change do
    alter table(:beat_maps) do
      add :complexity, :float, null: false, default: 1.0
    end
  end
end
