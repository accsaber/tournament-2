defmodule AccTournament.Repo.Migrations.AddHiddenDocPages do
  use Ecto.Migration

  def change do
    alter table(:doc_pages) do
      add :hidden, :boolean, default: false, null: false
    end
  end
end
