defmodule AccTournament.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :text
    end

    create table(:map_pools) do
      add :name, :text
      add :icon_id, :text
    end

    create table(:beat_maps) do
      add :name, :text
      add :artist, :text
      add :mapper, :text
      add :beatsaver_id, :text
      add :hash, :text
      add :difficulty, :integer
      add :max_score, :integer
      add :category_id, references(:categories, on_delete: :nothing)
      add :map_pool_id, references(:map_pools, on_delete: :nothing)

      add :map_type, :text,
        default: "Standard",
        null: false
    end

    create index(:beat_maps, [:category_id])
    create index(:beat_maps, [:map_pool_id])
  end
end
