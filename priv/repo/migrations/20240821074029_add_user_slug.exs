defmodule AccTournament.Repo.Migrations.AddUserSlug do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto", ""

    execute "ALTER TABLE users ADD COLUMN slug text GENERATED ALWAYS AS (replace(left(encode(digest(id::text, 'sha256'), 'base64'), 8), '/', '_')) STORED",
            "ALTER TABLE users DROP COLUMN slug"

    create unique_index(:users, [:slug])
  end
end
