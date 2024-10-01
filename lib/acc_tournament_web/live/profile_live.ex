defmodule AccTournamentWeb.ProfileLive do
  require Logger
  require Ecto.Query
  alias AccTournament.Levels.BeatMap
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

  def role_to_string(:staff) do
    "Staff"
  end

  defp campaign_icon(0), do: ~p"/images/campaign/mercenary.webp"
  defp campaign_icon(1), do: ~p"/images/campaign/champ.webp"
  defp campaign_icon(2), do: ~p"/images/campaign/elder.webp"
  defp campaign_icon(3), do: ~p"/images/campaign/god.webp"
  defp campaign_icon(4), do: ~p"/images/campaign/celestial.webp"

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
      <div class="w-full max-w-screen-lg isolate mx-auto relative p-8 py-20 flex flex-col md:flex-row md:items-center gap-4 md:gap-8">
        <%!-- dirty hack to reduce specificity --%>
        <span class="text-neutral-300 dark:text-neutral-600">
          <img
            class={[
              "w-24 md:w-40 lg:w-[11.5rem] aspect-square rounded-xl shadow-xl relative",
              "border-4 border-current"
            ]}
            src={User.public_avatar_url(@user)}
            srcSet={avatar_src_set(@user)}
            data-highest-milestone={@highest_milestone}
          />
        </span>
        <div class="flex flex-col flex-1 gap-3 relative">
          <div class="text-5xl flex gap-3 items-baseline flex-1 font-semibold flex-wrap">
            <%= case @highest_milestone do %>
              <% nil -> %>
                <.icon name="hero-cube-transparent" class="w-8 h-8 opacity-50 translate-y-0.5" />
              <% _ -> %>
                <img src={campaign_icon(@highest_milestone)} class="w-8 object-cover translate-y-0.5" />
            <% end %>
            <div
              data-highest-milestone={@highest_milestone}
              class="overflow-ellipsis overflow-hidden max-w-full py-6 -my-6"
            >
              <%= @user.display_name %>
            </div>

            <div class="bg-neutral-100 dark:bg-neutral-800 block text-xl relative bottom-1.5 px-2 rounded font-normal">
              <%= @user.pronouns %>
            </div>
          </div>
          <div class="text-3xl"><%= @user.headset %></div>
          <div class="flex flex-wrap gap-1.5 items-start">
            <div
              :for={role <- @user.roles}
              class="bg-yellow-300 text-black font-semibold shadow px-3.5 p-1.5 rounded flex flex-row gap-2 items-center h-9"
            >
              <%= role_to_string(role) %>
            </div>
            <%= for binding <- @user.account_bindings do %>
              <% service = @service_links[binding.service] %>
              <% field = service[:field] || :platform_id %>
              <.link
                :if={@service_links[binding.service]}
                title={service.name}
                href={
                  URI.merge(
                    service.prefix,
                    binding |> Map.get(field) |> String.Chars.to_string()
                  )
                }
                class="bg-white hover:bg-neutral-50 dark:hover:bg-neutral-700 dark:bg-neutral-800 shadow sm:px-2.5 size-9 sm:w-max rounded flex flex-row gap-2 items-center justify-center"
              >
                <img
                  src={service.logo}
                  alt={service.name}
                  class={["w-5 h-5", service[:invert] && "dark:invert"]}
                />
                <div class="hidden sm:block"><%= service.name %></div>
              </.link>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    <main class="w-full max-w-screen-lg mx-auto px-8">
      <div class="body prose lg:prose-lg prose-neutral dark:prose-invert max-w-none mb-16">
        <h2>Bio</h2>
        <%= raw(@bio) %>
        <em :if={!@bio}>No bio </em>
      </div>

      <div
        :if={length(@user.attempts) > 0}
        class="body prose lg:prose-lg prose-neutral dark:prose-invert max-w-none"
      >
        <h2>Qualifier Scores</h2>
      </div>

      <div :if={length(@user.attempts) > 0} class="grid md:grid-cols-2 gap-4 mt-4 mb-12">
        <%= for attempt <- @user.attempts do %>
          <.link
            navigate={~p"/qualifiers/map_leaderboard/#{attempt.map_id}"}
            class="rounded-xl bg-white dark:bg-neutral-800 shadow p-6 flex flex-col gap-6 overflow-hidden relative isolate"
          >
            <div class="flex flex-row gap-3">
              <img
                src={BeatMap.cover_url(attempt.map)}
                class="w-24 h-24 absolute blur-2xl rounded-full -z-10 scale-150 brightness-150 saturate-125 opacity-50 dark:opacity-100"
              />
              <img src={BeatMap.cover_url(attempt.map)} class="w-24 h-24 rounded" />
              <div class="flex flex-col gap-1 justify-center text-xl">
                <div class="text-xl font-semibold"><%= attempt.map.name %></div>
                <div class="text-sm"><%= attempt.map.mapper %></div>
                <div class="text-sm"><%= attempt.map.category.name %></div>
              </div>
            </div>
            <div class="flex flex-row gap-3 justify-between">
              <div class="text-3xl font-semibold">
                <div :if={attempt.score} class="flex gap-2 items-center">
                  <%= (attempt.score / attempt.map.max_score * 100)
                  |> :erlang.float_to_binary(decimals: 2) %>%
                </div>
              </div>
              <div :if={attempt.weight} class="text-3xl font-semibold">
                <%= :erlang.float_to_binary(attempt.weight, decimals: 2) %>AP
              </div>
            </div>
          </.link>
        <% end %>
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

  defp load_user() do
    import Ecto.Query, only: [from: 2, preload: 2]

    from(
      user in User,
      left_join: attempts in assoc(user, :attempts),
      distinct: attempts.map_id,
      preload: [
        :account_bindings,
        attempts: {attempts, [map: [:category]]}
      ]
    )
  end

  def handle_params(%{"id" => slug} = p, _, socket) do
    import Ecto.Query, only: [where: 2]

    user =
      load_user()
      |> where(slug: ^slug)
      |> Repo.one()

    if is_nil(user) do
      raise AccTournamentWeb.ProfileLive.UserNotFound
    end

    sanitised_friendly_name = user.display_name |> String.replace(~r/[^a-zA-Z0-9-_.~]+/, "")

    socket =
      case p do
        %{"friendly_name" => ^sanitised_friendly_name} ->
          socket

        _ ->
          new_path = ~p"/profile/#{slug}/@#{sanitised_friendly_name}"
          socket |> push_event("silent_new_url", %{to: new_path})
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
          },
          :discord => %{
            name: "Discord",
            prefix: "https://discord.com/users/",
            logo: ~p"/images/discord.svg"
          },
          :twitch => %{
            name: "Twitch",
            prefix: "https://twitch.tv/",
            field: :username,
            logo: ~p"/images/twitch.svg"
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
    import Ecto.Query, only: [where: 2]

    if user_id == current_user.id do
      user = load_user() |> where(id: ^user_id) |> Repo.one()

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
