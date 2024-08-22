defmodule AccTournamentWeb.ProfileLive do
  require Logger
  require Ecto.Query
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
    <div class="relative">
      <div class="dots-container absolute inset-0 overflow-hidden">
        <div class="absolute -inset-6 bottom-0 blur-[1.5rem]">
          <img
            class="object-cover w-full h-full"
            src={User.public_avatar_url(@user)}
            srcSet={avatar_src_set(@user)}
          />
        </div>
        <div class="dots" />
      </div>
      <div class="w-full max-w-screen-lg mx-auto relative p-8 py-20 flex flex-col md:flex-row md:items-center gap-4 md:gap-8">
        <div
          class={[
            "w-24 md:w-40 lg:w-[11.5rem] aspect-square relative rounded-xl",
            "overflow-hidden shadow-xl flex items-center justify-center",
            "text-neutral-300"
          ]}
          data-highest-milestone={@highest_milestone}
        >
          <img
            class="absolute top-0 left-0 w-full h-full object-cover"
            src={User.public_avatar_url(@user)}
            srcSet={avatar_src_set(@user)}
          />
        </div>
        <div class="flex flex-col flex-1 gap-3 relative">
          <div class="text-5xl flex gap-3 items-baseline flex-1 font-semibold flex-wrap">
            <span data-highest-milestone={@highest_milestone}><%= @user.display_name %></span>

            <div class="bg-neutral-100 dark:bg-neutral-800 block text-xl relative bottom-1.5 px-2 rounded font-normal">
              <%= @user.pronouns %>
            </div>
          </div>
          <div class="text-3xl"><%= @user.headset %></div>
          <div class="flex flex-wrap gap-1.5 items-start">
            <%= for %{service: service_id, platform_id: user_id} <- @user.account_bindings do %>
              <% service = @service_links[service_id] %>
              <.link
                :if={@service_links[service_id]}
                title={service.name}
                href={URI.merge(service.prefix, user_id |> Integer.to_string())}
                class="bg-white dark:bg-neutral-800 shadow px-2.5 py-1.5 rounded flex flex-row gap-2 items-center"
              >
                <img src={service.logo} alt={service.name} class="w-5 h-5 " />
                <%= service.name %>
              </.link>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <main :if={assigns[:bio]} class="w-full max-w-screen-lg mx-auto px-8">
      <div class="body prose lg:prose-lg prose-neutral dark:prose-invert max-w-none">
        <h2>Bio</h2>
        <%= raw(@bio) %>
      </div>
    </main>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(AccTournament.PubSub, @topic)
    end

    {:ok, socket |> assign(show_container: false)}
  end

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

    if is_nil(user) do
      raise AccTournamentWeb.ProfileLive.UserNotFound
    end

    bio_rendered = if(user.bio, do: user.bio |> Earmark.as_html!())

    highest_milestone =
      user.account_bindings
      |> Enum.map(fn %{platform_id: platform_id} ->
        milestone_url =
          Application.get_env(:acc_tournament, :campaigns_url)
          |> URI.append_path("/0/player-campaign-infos/#{platform_id}")

        Task.async(fn ->
          case Req.get(milestone_url) do
            {:ok, %{status: 200, body: milestones}} ->
              milestones

            _ ->
              nil
          end
        end)
      end)
      |> Task.await_many()
      |> List.flatten()
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.map(& &1["milestoneId"])
      |> case do
        [] -> nil
        milestones -> Enum.reduce(milestones, 0, &max(&1, &2))
      end

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
       page_title: user.display_name,
       highest_milestone: highest_milestone
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
