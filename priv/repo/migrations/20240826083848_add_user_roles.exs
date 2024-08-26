defmodule AccTournament.Repo.Migrations.AddUserRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :roles, {:array, :text}, default: []
    end
  end
end
