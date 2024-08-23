defmodule AccTournamentWeb.UserSettingsLive do
  alias AccTournament.Accounts.Binding
  alias AccTournament.Repo
  alias AccTournament.Accounts.User
  use AccTournamentWeb, :live_view
  require Ecto.Query

  defp broadcast_update(user) do
    Phoenix.PubSub.broadcast(AccTournament.PubSub, "user_profile", {:user_updated, user})
  end

  def handle_event("validate_user_settings", %{"user" => new_user}, socket) do
    user = socket.assigns.current_user

    changeset =
      user
      |> User.display_name_changeset(new_user)
      |> User.headset_changeset(new_user)
      |> User.pronouns_changeset(new_user)
      |> User.bio_changeset(new_user)

    {:noreply,
     socket
     |> assign(
       :user_settings_form,
       to_form(changeset)
     )}
  end

  def handle_event("validate_avatar", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save_avatar", _params, socket) do
    user = socket.assigns.current_user

    entries =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        binary = File.read!(path)

        <<hash::binary-size(4), _::binary>> = :crypto.hash(:sha256, binary)

        filename = "#{user.slug}-#{hash |> Base.encode16()}"

        basename = Application.fetch_env!(:acc_tournament, :uploads_dir)

        originals_dir =
          Path.join(basename, "avatar_originals")

        File.mkdir_p!(originals_dir)

        avatars_dir =
          Path.join(basename, "avatars")

        File.mkdir_p!(avatars_dir)

        path
        |> File.cp!(
          Path.join(
            originals_dir,
            filename <> Path.extname(entry.client_name)
          )
        )

        [_ | sizes] =
          [{192, ""}, {384, "2x"}]
          |> Enum.map(
            &Task.async(fn ->
              {size, suffix} = &1

              filename =
                case suffix do
                  "" -> filename <> ".webp"
                  _ -> filename <> "@" <> suffix <> ".webp"
                end

              outfile =
                Path.join(
                  avatars_dir,
                  filename
                )

              Image.open!(binary)
              |> Image.thumbnail!(size, crop: :center)
              |> Image.write!(outfile, effort: 6, quality: 90)

              suffix
            end)
          )
          |> Enum.map(&Task.await(&1))

        user =
          user
          |> User.avatar_changeset(%{
            avatar_url: "upload:avatars/" <> filename,
            avatar_sizes: sizes
          })
          |> Repo.update!()

        {:ok, user}
      end)

    case entries do
      [new_user | _] ->
        broadcast_update(user)

        {:noreply, socket |> put_flash(:info, "Avatar updated") |> assign(current_user: new_user)}

      _ ->
        {:noreply, socket |> put_flash(:error, "No image selected")}
    end
  end

  def handle_event("update_user_settings", %{"user" => new_user}, socket) do
    user = socket.assigns.current_user

    changeset =
      user
      |> User.display_name_changeset(new_user)
      |> User.headset_changeset(new_user)
      |> User.pronouns_changeset(new_user)
      |> User.bio_changeset(new_user)

    action = changeset |> Ecto.Changeset.apply_action(:update)

    case action do
      {:ok, user} ->
        Repo.update!(changeset)

        broadcast_update(user)

        {:noreply,
         socket
         |> assign(current_user: user)
         |> put_flash(:info, "User settings changed")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(
           :user_settings_form,
           to_form(changeset)
         )}
    end
  end

  defp upload_error_to_string(:too_large), do: "Image too large"

  defp upload_error_to_string(:not_accepted),
    do: "You have selected an unacceptable file type (accepted types: jpg, png, webp)"

  defp upload_error_to_string(:external_client_failure), do: "?????"

  def render(assigns) do
    ~H"""
    <form
      phx-submit="save_avatar"
      phx-change="validate_avatar"
      class="mb-4 not-prose"
      phx-drop-target={@uploads.avatar.ref}
    >
      <.header>Update avatar</.header>
      <.live_file_input upload={@uploads.avatar} />
      <img src={User.public_avatar_url(@current_user)} class="w-24 h-24 rounded object-cover" />
      <%= for entry <- @uploads.avatar.entries do %>
        <div class="flex gap-2 shadow p-2 w-max">
          <.live_img_preview entry={entry} class="w-24 h-24 rounded object-cover" />

          <div class="flex flex-col gap-2 justify-between flex-1">
            <%= entry.client_name %>
            <progress value={entry.progress} max="100" class="rounded">
              <%= entry.progress %>%
            </progress>
          </div>

          <%= for err <- upload_errors(@uploads.avatar, entry) do %>
            <p class="alert alert-danger"><%= upload_error_to_string(err) %></p>
          <% end %>
        </div>
      <% end %>
      <.button :if={@uploads.avatar.entries != []} type="submit">Upload</.button>
    </form>
    <%= case @bindings |> Enum.filter(&(&1.service == :discord)) do %>
      <% [] -> %>
        <form
          action="https://discord.com/oauth2/authorize"
          class=" mx-auto mb-4 flex flex-col gap-2 not-prose"
        >
          <input
            type="hidden"
            name="client_id"
            value={Application.fetch_env!(:acc_tournament, :discord_client_id)}
          />
          <input type="hidden" name="response_type" value="code" />
          <input type="hidden" name="scope" value="identify" />
          <input
            type="hidden"
            name="redirect_uri"
            value={AccTournamentWeb.OAuthLoginController.discord_redirect_uri()}
          />
          <.button class="flex w-max gap-3 !rounded" type="submit">
            <img src={~p"/images/discord.svg"} class="h-6 w-6 invert" />
            <div class="mx-auto">
              Link Discord
            </div>
          </.button>
        </form>
      <% _ -> %>
        <div class="form-root mb-3">
          <div class="bg-neutral-100 dark:bg-neutral-800 flex gap-4 w-max py-1.5 px-3 rounded items-center not-prose">
            <img src={~p"/images/discord.svg"} class="h-6 w-6 dark:invert" /> Discord linked
          </div>
        </div>
    <% end %>
    <.form
      for={@user_settings_form}
      phx-change="validate_user_settings"
      phx-submit="update_user_settings"
      class=" mx-auto mb-4 flex flex-col gap-2"
    >
      <.input field={@user_settings_form[:display_name]} label="Display name" />
      <.input
        type="select"
        field={@user_settings_form[:pronouns]}
        label="Pronouns"
        prompt="Choose pronouns"
        options={
          [
            "he/him",
            "she/her",
            "they/them"
          ]
          |> Enum.map(&{&1, &1})
        }
      />
      <.input
        type="select"
        field={@user_settings_form[:headset]}
        label="Headset"
        prompt="Choose headset"
        options={
          [
            "Valve Index",
            "Meta Quest 2",
            "Meta Quest 3",
            "Oculus CV1",
            "Oculus Rift S",
            "HTC Vive",
            "Other"
          ]
          |> Enum.map(&{&1, &1})
        }
      />
      <.input type="textarea" field={@user_settings_form[:bio]} label="Bio (Markdown supported)" />
      <.button type="submit" class="mt-2">Save</.button>
    </.form>
    """
  end

  def mount(_, _, socket) do
    user = socket.assigns.current_user
    import Ecto.Query, only: [where: 2]

    bindings = Binding |> where(user_id: ^user.id) |> Repo.all()

    {:ok,
     socket
     |> assign(bindings: bindings)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 3_000_000,
       allow_upload: true
     )
     |> assign(user_settings_form: to_form(user |> User.display_name_changeset(%{})))}
  end
end
