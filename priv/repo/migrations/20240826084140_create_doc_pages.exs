defmodule AccTournament.Repo.Migrations.CreateDocPages do
  use Ecto.Migration

  def change do
    create table(:doc_pages) do
      add :title, :text, null: false
      add :slug, :citext, null: false
      add :body, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:doc_pages, [:slug])
  end
end
