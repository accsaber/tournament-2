defmodule AccTournament.Repo.Migrations.CreateAccountBinding do
  use Ecto.Migration

  def change do
    create table(:account_binding) do
      add :service, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :platform_id, :bigint, null: false

      timestamps()
    end

    create index(:account_binding, [:user_id])
  end
end
