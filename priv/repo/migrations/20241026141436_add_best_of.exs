defmodule AccTournament.Repo.Migrations.AddBestOf do
  use Ecto.Migration

  def change do
    alter table(:rounds) do
      add :best_of, :integer, default: 3
    end
  end
end
