defmodule AccTournament.Repo.Migrations.UsernameField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:display_name, :text)
    end
  end
end
