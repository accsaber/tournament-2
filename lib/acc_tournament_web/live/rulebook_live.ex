defmodule AccTournamentWeb.RulebookLive do
  alias AccTournament.Accounts.User
  alias AccTournament.Rulebook.Page
  use AccTournamentWeb, :live_view
  alias AccTournament.Repo

  def mount(_params, _session, socket) do
    import Ecto.Query, only: [from: 2]
    pages = from(p in Page, order_by: [asc: p.id], where: not p.hidden) |> Repo.all()
    {:ok, socket |> assign(pages: pages, route: :rules)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2 mb-8 border p-2 rounded-lg border-neutral-200 dark:border-neutral-800 items-center">
      <.link
        :for={page <- @pages}
        navigate={~p"/rules/#{page.slug}"}
        class={[
          "rulebook-tab"
        ]}
        data-active={if(@page.slug == page.slug, do: "true")}
      >
        <%= page.title %>
      </.link>

      <%= if(@current_user && @current_user.roles |> Enum.member?(:staff)) do %>
        <.link class={["rulebook-tab", "px-1 ml-auto"]} navigate={~p"/rules/new"}>
          <.icon name="hero-plus" class="w-6 h-6" />
        </.link>
        <div class="w-px h-10 bg-neutral-100 dark:bg-neutral-800" />
        <.link class={["rulebook-tab", "px-1"]} data-active="true" navigate={~p"/rules/#{@page.slug}"}>
          <.icon name="hero-book-open" class="w-6 h-6" />
        </.link>
        <.link class={["rulebook-tab", "px-1"]} navigate={~p"/rules/#{@page.slug}/edit"}>
          <.icon name="hero-pencil" class="w-6 h-6" />
        </.link>
      <% end %>
    </div>
    <div class="prose max-w-none dark:prose-invert">
      <h1><%= @page.title %></h1>
      <%= raw(@body) %>
    </div>
    """
  end

  def handle_params(%{"slug" => slug}, _uri, socket) do
    AccTournament.Rulebook.Page
    |> Repo.get_by(slug: slug)
    |> case do
      %Page{} = page ->
        rendered = Earmark.as_html!(page.body)

        {:noreply,
         socket
         |> assign(page: page, body: rendered)
         |> assign(page_title: page.title)}

      _ ->
        case socket.assigns do
          %{current_user: %User{} = user} ->
            if user.roles |> Enum.member?(:staff) do
              {:noreply,
               socket |> push_navigate(to: ~p"/rules/new/#{URI.encode(slug)}", replace: true)}
            else
              raise AccTournamentWeb.RulebookLive.PageNotFound
            end

          _ ->
            raise AccTournamentWeb.RulebookLive.PageNotFound
        end
    end
  end

  def handle_params(params, uri, socket),
    do: handle_params(params |> Map.put("slug", "home"), uri, socket)
end

defmodule AccTournamentWeb.RulebookLive.PageNotFound do
  defexception message: "Page not found", plug_status: 404
end
