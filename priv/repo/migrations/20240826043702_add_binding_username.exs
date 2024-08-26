defmodule AccTournament.Repo.Migrations.AddBindingUsername do
  use Ecto.Migration

  def change do
    alter table(:account_binding) do
      add :username, :text
    end
  end
end
