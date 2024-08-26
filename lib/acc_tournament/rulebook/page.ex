defmodule AccTournament.Rulebook.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "doc_pages" do
    field :title, :string
    field :body, :string
    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :slug, :body])
    |> validate_required([:title, :slug, :body])
  end
end
