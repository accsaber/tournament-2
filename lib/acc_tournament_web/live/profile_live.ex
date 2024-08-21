defmodule AccTournamentWeb.ProfileLive do
  require Logger
  require Ecto.Query
  alias AccTournament.Levels.Category
  alias AccTournament.Levels.MapPool
  alias AccTournament.Accounts.User
  alias AccTournament.Repo
  use AccTournamentWeb, :live_view

  @topic "user_profile"

  defp avatar_src_set(user) do
    if(user.avatar_url && user.avatar_sizes,
      do:
        user.avatar_sizes
        |> Enum.reverse()
        |> Enum.map(&"#{User.public_avatar_url(user, &1)} #{&1}")
        |> Enum.join(", ")
    )
  end

  def render(assigns) do
    ~H"""
    <img
      src={User.public_avatar_url(@user)}
      srcSet={avatar_src_set(@user)}
      class="absolute top-0 left-0 w-full h-96 pointer-events-none object-cover gradient-transparent blur-xl opacity-70"
    />
    <div class="flex flex-col md:flex-row items-start md:items-center md:gap-8 relative max-w-screen-lg px-6 mx-auto pt-12">
      <img
        src={User.public_avatar_url(@user)}
        srcSet={avatar_src_set(@user)}
        class="w-24 md:w-40 lg:w-[11.5rem] aspect-square rounded-xl shadow-xl"
      />
      <div class="flex flex-col gap-1.5 py-3.5 w-full">
        <div class="flex flex-col md:flex-row items-start gap-3 mb-2   md:items-end">
          <h1 class="text-5xl items-baseline font-semibold ">
            <%= @user.display_name %>
          </h1>
        </div>
        <div class="flex flex-wrap gap-1.5 items-start">
          <div :if={@user.headset} class="country-badge"><%= @user.headset %></div>
          <div :if={@user.pronouns} class="country-badge"><%= @user.pronouns %></div>

          <%= for %{service: service_id, platform_id: user_id} <- @user.account_bindings do %>
            <% service = @service_links[service_id] %>
            <.link
              :if={@service_links[service_id]}
              title={service.name}
              href={URI.merge(service.prefix, user_id |> Integer.to_string())}
              class="bg-neutral-100 px-2.5 py-1.5 hover:bg-neutral-200 rounded flex flex-row gap-2 items-center"
            >
              <img src={service.logo} alt={service.name} class="w-5 h-5 " />
              <%= service.name %>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    <div class="max-w-screen-lg px-6 mx-auto">
      <div :if={@bio} class="flex flex-col gap-1 p-4 py-6 relative card mt-8 shadow">
        <.header>Bio</.header>
        <div class="prose max-w-none">
          <%= raw(@bio) %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AccTournament.PubSub, @topic)
    end

    {:ok, socket}
  end

  @preload_cols [:account_bindings, :country, [playstyles: :category]]

  defp load_user(user_id) do
    import Ecto.Query, only: [from: 2, preload: 2]

    from(
      user in User,
      where: user.id == ^user_id,
      preload: [
        :account_bindings
      ]
    )
  end

  @spec handle_params(map(), any(), any()) :: {:noreply, any()}
  def handle_params(%{"id" => slug}, _, socket) do
    import Ecto.Query, only: [from: 2]

    query =
      from(
        user in User,
        where: user.slug == ^slug,
        preload: [
          :account_bindings
        ]
      )

    user = Repo.one(query)

    bio_rendered = if(user.bio, do: user.bio |> Earmark.as_html!())

    socket =
      socket
      |> assign(
        service_links: %{
          :beatleader => %{
            name: "BeatLeader",
            prefix: "https://beatleader.xyz/u/",
            logo: ~p"/images/beatleader.svg"
          },
          :scoresaber => %{
            name: "ScoreSaber",
            prefix: "https://scoresaber.com/u/",
            logo: ~p"/images/scoresaber.svg"
          }
        },
        bio: bio_rendered
      )

    {:noreply,
     socket
     |> assign(
       user: user,
       page_title: user.display_name
     )}
  end

  def handle_info(
        {:user_updated, %{id: user_id} = _incoming_user},
        %{assigns: %{user: current_user}} = socket
      ) do
    if user_id == current_user.id do
      user = load_user(user_id) |> Repo.one()

      bio_rendered = if(user.bio, do: user.bio |> Earmark.as_html!())

      {:noreply,
       socket
       |> assign(user: user, page_title: user.display_name, bio: bio_rendered)}
    else
      {:noreply, socket}
    end
  end
end

defmodule AccTournamentWeb.ProfileLive.UserNotFound do
  defexception message: "No user with such id", plug_status: 404
end
