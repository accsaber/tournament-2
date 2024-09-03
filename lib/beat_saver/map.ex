defmodule BeatSaver.Map do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :description, :string
    embeds_one :uploader, BeatSaver.Map.Uploader
    embeds_one :metadata, BeatSaver.Map.Metadata
    embeds_one :stats, BeatSaver.Map.Stats
    field :uploaded, :utc_datetime
    field :automapper, :boolean
    field :ranked, :boolean
    field :qualified, :boolean
    embeds_many :versions, BeatSaver.Map.Version
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :last_published_at, :utc_datetime
    field :tags, {:array, :string}
    field :bookmarked, :boolean
    field :declared_ai, :string
    field :bl_ranked, :boolean
    field :bl_qualified, :boolean
  end

  defmodule Uploader do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :id, :integer
      field :name, :string
      field :avatar, :string
      field :type, :string
      field :admin, :boolean
      field :curator, :boolean
      field :senior_curator, :boolean
      field :playlist_url, :string
    end

    def changeset(%BeatSaver.Map.Uploader{} = uploader, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      uploader
      |> cast(attrs, [
        :id,
        :name,
        :avatar,
        :type,
        :admin,
        :curator,
        :senior_curator,
        :playlist_url
      ])
      |> validate_required([:id, :name, :type])
    end
  end

  defmodule Metadata do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :bpm, :float
      field :duration, :integer
      field :song_name, :string
      field :song_sub_name, :string
      field :song_author_name, :string
      field :level_author_name, :string
    end

    def changeset(%BeatSaver.Map.Metadata{} = metadata, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      metadata
      |> cast(attrs, [
        :bpm,
        :duration,
        :song_name,
        :song_sub_name,
        :song_author_name,
        :level_author_name
      ])
      |> validate_number(:bpm, greater_than: 0)
      |> validate_number(:duration, greater_than: 0)
    end
  end

  defmodule Stats do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :plays, :integer
      field :downloads, :integer
      field :upvotes, :integer
      field :downvotes, :integer
      field :score, :float
      field :reviews, :integer
    end

    def changeset(%BeatSaver.Map.Stats{} = stats, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      stats
      |> cast(attrs, [:plays, :downloads, :upvotes, :downvotes, :score, :reviews])
      |> validate_required([:plays, :downloads, :upvotes, :downvotes, :score])
      |> validate_number(:score, greater_than_or_equal_to: 0, less_than_or_equal_to: 1)
    end
  end

  defmodule Version do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :hash, :string
      field :state, :string
      field :created_at, :utc_datetime
      field :sage_score, :integer
      embeds_many :diffs, BeatSaver.Map.Diff
      field :download_url, :string
      field :cover_url, :string
      field :preview_url, :string
    end

    def changeset(%BeatSaver.Map.Version{} = version, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      version
      |> cast(attrs, [
        :hash,
        :state,
        :created_at,
        :sage_score,
        :download_url,
        :cover_url,
        :preview_url
      ])
      |> validate_required([:hash, :state, :created_at, :download_url])
      |> cast_embed(:diffs, with: &BeatSaver.Map.Diff.changeset/2)
    end
  end

  defmodule Diff do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :njs, :float
      field :offset, :float
      field :notes, :integer
      field :bombs, :integer
      field :obstacles, :integer
      field :nps, :float
      field :length, :float
      field :characteristic, :string
      field :difficulty, :string
      field :events, :integer
      field :chroma, :boolean
      field :me, :boolean
      field :ne, :boolean
      field :cinema, :boolean
      field :seconds, :float
      embeds_one :parity_summary, BeatSaver.Map.ParitySummary
      field :max_score, :integer
    end

    def changeset(%BeatSaver.Map.Diff{} = diff, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      diff
      |> cast(attrs, [
        :njs,
        :offset,
        :notes,
        :bombs,
        :obstacles,
        :nps,
        :length,
        :characteristic,
        :difficulty,
        :events,
        :chroma,
        :me,
        :ne,
        :cinema,
        :seconds,
        :max_score
      ])
      |> validate_required([:njs, :notes, :characteristic, :difficulty])
      |> cast_embed(:parity_summary, with: &BeatSaver.Map.ParitySummary.changeset/2)
    end
  end

  defmodule ParitySummary do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :errors, :integer
      field :warns, :integer
      field :resets, :integer
    end

    def changeset(%BeatSaver.Map.ParitySummary{} = parity_summary, attrs) do
      attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

      parity_summary
      |> cast(attrs, [:errors, :warns, :resets])
      |> validate_required([:errors, :warns, :resets])
    end
  end

  def changeset(%BeatSaver.Map{} = map, attrs) do
    attrs = for {key, val} <- attrs, into: %{}, do: {Macro.underscore(to_string(key)), val}

    map
    |> cast(attrs, [
      :id,
      :name,
      :description,
      :uploaded,
      :automapper,
      :ranked,
      :qualified,
      :created_at,
      :updated_at,
      :last_published_at,
      :tags,
      :bookmarked,
      :declared_ai,
      :bl_ranked,
      :bl_qualified
    ])
    |> validate_required([:id, :name, :uploaded, :created_at, :updated_at])
    |> cast_embed(:uploader, with: &BeatSaver.Map.Uploader.changeset/2)
    |> cast_embed(:metadata, with: &BeatSaver.Map.Metadata.changeset/2)
    |> cast_embed(:stats, with: &BeatSaver.Map.Stats.changeset/2)
    |> cast_embed(:versions, with: &BeatSaver.Map.Version.changeset/2)
  end

  def get_by_hash(hash),
    do:
      Req.get("https://beatsaver.com/api/maps/hash/#{hash}")
      |> parse_response()

  def get_by_id(id),
    do:
      Req.get("https://beatsaver.com/api/maps/id/#{id}")
      |> parse_response()

  defp parse_response(response) do
    case response do
      {:ok, %{status: 200, body: body}} ->
        body =
          body
          |> Enum.map(fn {k, v} -> {Macro.underscore(k), v} end)
          |> Enum.into(%{})

        changeset = BeatSaver.Map.changeset(%BeatSaver.Map{}, body)

        case changeset do
          %{valid?: true} ->
            {:ok, apply_changes(changeset)}

          _ ->
            {:error, changeset}
        end

      {:ok, %{status: 404}} ->
        {:error, "Map not found"}

      _ ->
        {:error, "Couldn't load map"}
    end
  end
end
