defmodule AccTournament.Accounts.Binding do
  use Ecto.Schema
  import Ecto.Changeset

  schema "account_binding" do
    field :service, Ecto.Enum, values: [:beatleader, :scoresaber]
    field :platform_id, :integer
    belongs_to :user, AccTournament.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(binding, attrs) do
    binding
    |> cast(attrs, [:service, :id])
    |> validate_required([:service, :id])
  end
end