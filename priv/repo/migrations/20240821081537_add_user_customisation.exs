defmodule AccTournament.Repo.Migrations.AddUserCustomisation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:pronouns, :text)
      add(:headset, :text)
      add(:bio, :text)

      add(:avatar_url, :text)
      add(:avatar_sizes, {:array, :text}, default: [])
    end
  end
end
