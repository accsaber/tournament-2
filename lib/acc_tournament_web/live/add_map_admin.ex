defmodule AccTournamentWeb.AdminAddMapLive.HashForm do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :hash, :string
  end

  def changeset(struct, params) do
    import Ecto.Changeset

    struct
    |> cast(params, [:hash])
    |> validate_required([:hash])
    |> validate_format(:hash, ~r/^([a-fA-F0-9]{40}$)|(?:^!bsr ([a-fA-F0-9]{1,6})$)/,
      message: "Must be a valid hash or !bsr command"
    )
  end
end

defmodule AccTournamentWeb.AdminAddMapLive do
  alias AccTournamentWeb.AdminAddMapLive.HashForm
  alias AccTournament.Levels.BeatMap
  use AccTournamentWeb, :live_view

  def render(%{} = assigns) do
    ~H"""
    <.header>
      Edit map pool <strong><%= @map_pool.name %></strong>
    </.header>
    <.form phx-change="validate_hash" phx-submit="fill_beatsaver_info" for={@hash_form}>
      <div class="flex items-start gap-2 my-2">
        <div class="flex-1 w-full">
          <.input type="text" field={@hash_form[:hash]} placeholder="Map hash or !bsr command" />
        </div>
        <.button
          type="submit"
          class="h-10 w-max flex items-center "
          disabled={!@hash_form.source.valid?}
        >
          <.icon name="hero-magnifying-glass" class="w-4 h-4" />
        </.button>
      </div>
    </.form>

    <%= case @beatsaver_map do %>
      <% {:loading, _} -> %>
        <div class="flex gap-2 items-center justify-center p-6">
          <.icon name="hero-arrow-path" class="w-8 h-8 animate-spin" /> Loading...
        </div>
      <% {:error, message}  -> %>
        <div class="text-red-600 dark:text-red-400 mt-4"><%= message %></div>
      <% {:ok, %BeatSaver.Map{versions: [data]} = map} -> %>
        <div class="flex flex-col gap-2 mt-4">
          <div class="flex items-center gap-4">
            <img src={data.cover_url} class="w-32 h-32 rounded-lg shadow" />
            <div class="flex flex-col ">
              <div class="text-2xl font-semibold">
                <%= map.metadata.song_name %>
                <small :if={map.metadata.song_sub_name} class="ml-1 opacity-70">
                  <%= map.metadata.song_sub_name %>
                </small>
              </div>
              <div class="text-xl"><%= map.metadata.song_author_name %></div>
              <div class="text-xl"><%= map.metadata.level_author_name %></div>
            </div>
          </div>
          <.form for={@beat_map_form} phx-change="validate_beat_map" phx-submit="save">
            <.input field={@beat_map_form[:name]} label="Name" />
            <.input field={@beat_map_form[:artist]} label="Artist" />
            <.input field={@beat_map_form[:mapper]} label="Mapper" />

            <.input
              label="Difficulty"
              type="select"
              prompt="Select a difficulty"
              field={@beat_map_form[:difficulty]}
              options={
                data.diffs
                |> Enum.filter(
                  &(&1.characteristic == (@beat_map_form.params["map_type"] || "Standard"))
                )
                |> Enum.map(&{&1.difficulty, BeatMap.difficulty_string_to_int(&1.difficulty)})
              }
            />
            <details>
              <summary class="bg-neutral-100 dark:bg-neutral-800 rounded p-2 px-3 select-none cursor-pointer">
                Advanced options (You probably don't need to change these)
              </summary>
              <div class="form-root mt-2">
                <.input field={@beat_map_form[:beatsaver_id]} label="BeatSaver ID" type="text" />

                <.input
                  field={@beat_map_form[:map_type]}
                  label="Type"
                  type="select"
                  options={
                    data.diffs |> Enum.map(& &1.characteristic) |> Enum.uniq() |> Enum.map(&{&1, &1})
                  }
                />
                <.input
                  field={@beat_map_form[:max_score]}
                  label="Max score"
                  type="number"
                  placeholder="Auto-filled once a difficulty is selected "
                />
                <.input field={@beat_map_form[:hash]} label="Hash" />
              </div>
            </details>
            <div class="flex gap-2">
              <.button type="submit" class="flex-1">Save</.button>
            </div>
          </.form>
        </div>
      <% _ -> %>
    <% end %>
    """
  end

  def handle_info(
        {:beat_map_loaded, :ok, %BeatSaver.Map{id: _id, versions: [version]} = beat_map},
        socket
      ) do
    {:noreply,
     socket
     |> assign(
       beatsaver_map: {:ok, beat_map},
       beat_map_form:
         to_form(
           BeatMap.changeset(%BeatMap{}, %{
             name: beat_map.metadata.song_name,
             artist: beat_map.metadata.song_author_name,
             mapper: beat_map.metadata.level_author_name,
             hash: version.hash |> String.upcase(),
             beatsaver_id: beat_map.id,
             map_type: version.diffs |> List.first() |> Map.get(:characteristic)
           })
         )
     )}
  end

  def handle_info({:beat_map_loaded, :error, reason}, socket) do
    {:noreply, assign(socket, beatsaver_map: {:error, reason})}
  end

  def handle_info({:prefill_beat_map, _}, socket), do: {:noreply, socket}

  def handle_event(
        "validate_beat_map",
        %{"beat_map" => form_data} = params,
        socket
      ) do
    form_data =
      case params do
        %{
          "_target" => ["beat_map", "difficulty"],
          "beat_map" => %{"difficulty" => difficulty, "map_type" => characteristic}
        } ->
          {:ok, %{versions: [version]}} = socket.assigns.beatsaver_map

          IO.inspect(difficulty)

          matched_diff =
            version.diffs
            |> Enum.find(
              &(&1.difficulty == BeatMap.difficulty_int_to_string(difficulty) &&
                  &1.characteristic == characteristic)
            )

          case matched_diff do
            nil ->
              form_data

            _ ->
              form_data
              |> Map.put("map_type", matched_diff.characteristic)
              |> Map.put("max_score", matched_diff.max_score)
          end

        _ ->
          form_data
      end

    changeset =
      BeatMap.changeset(%BeatMap{}, form_data)
      |> Map.put(:action, :insert)

    {:noreply, socket |> assign(beat_map_form: to_form(changeset))}
  end

  def handle_event("save", %{"beat_map" => map}, socket) do
    changeset =
      BeatMap.changeset(%BeatMap{map_pool_id: socket.assigns.map_pool.id}, map)
      |> Ecto.Changeset.apply_action(:insert)

    case changeset do
      {:ok, map} ->
        AccTournament.Repo.insert(map)
        |> case do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Map saved")
             |> push_navigate(to: ~p"/map_pools/#{socket.assigns.map_pool.id}")}

          {:error, changeset} ->
            {:noreply,
             socket
             |> assign(beat_map_form: to_form(changeset))
             |> put_flash(:error, "Couldn't save map")}
        end

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(beat_map_form: to_form(changeset))}
    end
  end

  def handle_event("validate_hash", %{"hash_form" => form_data}, socket) do
    changeset =
      HashForm.changeset(%HashForm{}, form_data)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(hash_form: to_form(changeset))}
  end

  def handle_event("fill_beatsaver_info", %{"hash_form" => form_data}, socket) do
    changeset =
      HashForm.changeset(%HashForm{}, form_data)
      |> Map.put(:action, :validate)

    socket = socket |> assign(hash_form: to_form(changeset))

    if is_pid(socket.assigns[:get_map_task]) do
      Task.shutdown(socket.assigns.get_map_task)
    end

    me = self()

    get_map_task =
      Task.start_link(fn ->
        case changeset.changes do
          %{hash: "!bsr " <> key} ->
            BeatSaver.Map.get_by_id(key)

          %{hash: hash} ->
            BeatSaver.Map.get_by_hash(hash)
        end
        |> case do
          {:ok, map} ->
            send(me, {:beat_map_loaded, :ok, map})

          {:error, reason} ->
            send(me, {:beat_map_loaded, :error, reason})
        end
      end)

    if(changeset.valid?) do
      {:noreply,
       socket
       |> assign(beatsaver_map: {:loading, nil}, get_map_task: get_map_task)}
    else
      {:noreply, socket}
    end
  end

  def mount(_params, _session, socket) do
    hash_form = to_form(HashForm.changeset(%HashForm{}, %{}))
    beat_map_form = to_form(BeatMap.changeset(%BeatMap{map_type: "Standard"}, %{}))

    {:ok,
     socket
     |> assign(
       beat_map_form: beat_map_form,
       hash_form: hash_form,
       beatsaver_map: nil,
       map_pool: nil
     )}
  end

  def handle_params(%{"map_pool_id" => map_pool_id}, _uri, socket) do
    {:noreply,
     socket
     |> assign(map_pool: AccTournament.Levels.get_map_pool!(map_pool_id))}
  end
end
