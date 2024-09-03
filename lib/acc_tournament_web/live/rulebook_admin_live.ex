defmodule AccTournamentWeb.RulebookAdminLive do
  use AccTournamentWeb, :live_view
  alias AccTournament.Rulebook.Page
  alias AccTournament.Repo

  def mount(_params, _session, socket) do
    import Ecto.Query, only: [from: 2]
    pages = from(p in Page, order_by: [asc: p.id]) |> Repo.all()
    {:ok, socket |> assign(pages: pages, route: :rules, page: nil)}
  end

  def handle_params(params, _uri, %{assigns: %{live_action: :new}} = socket) do
    {:noreply,
     socket
     |> assign(
       page: %Page{},
       form:
         to_form(
           Page.changeset(
             %Page{
               slug: params["slug"]
             },
             %{}
           )
         ),
       page_title: "New Page"
     )}
  end

  def handle_params(%{"slug" => slug}, _uri, socket) do
    AccTournament.Rulebook.Page
    |> Repo.get_by(slug: slug)
    |> case do
      %Page{} = page ->
        {:noreply,
         socket
         |> assign(
           form: to_form(page |> Page.changeset(%{})),
           page: page,
           page_title: page.title
         )}

      _ ->
        {:noreply, push_navigate(socket, to: ~p"/rules/new/#{URI.encode(slug)}", replace: true)}
    end
  end

  def handle_event("validate", %{"page" => page}, socket) do
    {:noreply,
     socket
     |> assign(form: to_form(socket.assigns.page |> Page.changeset(page)))}
  end

  def handle_event("delete", _params, socket) do
    Repo.delete!(socket.assigns.page)
    {:noreply, socket |> push_navigate(to: ~p"/rules") |> put_flash(:info, "Page deleted")}
  end

  def handle_event("save", %{"page" => page}, socket) do
    changeset = socket.assigns.page |> Page.changeset(page)

    case changeset |> Ecto.Changeset.apply_action(:update) do
      {:ok, _} ->
        case socket.assigns.page do
          %Page{id: nil} ->
            Repo.insert!(changeset)

          %Page{} ->
            Repo.update!(changeset)
        end
        |> case do
          %Page{} = page ->
            {
              :noreply,
              socket
              |> put_flash(:info, "Page saved")
              |> push_navigate(to: ~p"/rules/#{page.slug}/edit", replace: true)
            }

          _ ->
            raise AccTournamentWeb.RulebookLive.PageNotFound
        end

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2 mb-8 border p-2 rounded-lg border-neutral-200 dark:border-neutral-800 items-center">
      <.link
        :for={page <- @pages}
        navigate={~p"/rules/#{page.slug}/edit"}
        class={[
          "rulebook-tab"
        ]}
        data-active={if(@page.id && @page.slug == page.slug, do: "true")}
      >
        <%= page.title %>
      </.link>
      <.link
        class={["rulebook-tab", "px-1", "ml-auto"]}
        navigate={~p"/rules/new"}
        data-active={is_nil(@page.id)}
      >
        <.icon name="hero-plus" class="w-6 h-6" />
      </.link>
      <div class="w-px h-10 bg-neutral-100 dark:bg-neutral-800" />
      <.link
        :if={!is_nil(@page.id)}
        class={["rulebook-tab", "px-1"]}
        navigate={~p"/rules/#{@page.slug}"}
      >
        <.icon name="hero-book-open" class="w-6 h-6" />
      </.link>
      <div :if={@live_action == :new} class={["rulebook-tab", "px-1 opacity-50 pointer-events-none"]}>
        <.icon name="hero-book-open" class="w-6 h-6" />
      </div>
      <div class={["rulebook-tab", "px-1"]} data-active="true">
        <.icon name="hero-pencil" class="w-6 h-6" />
      </div>
    </div>

    <.form for={@form} method="post" phx-change="validate" phx-submit="save">
      <.input field={@form[:title]} label="Title" />
      <.input :if={@page.slug != "home"} field={@form[:slug]} label="Slug" />
      <.input field={@form[:body]} label="Body" type="textarea" class="h-[32rem]" />
      <.input field={@form[:hidden]} label="Hidden" type="checkbox" />
      <div class="flex gap-2">
        <.button type="submit" class="flex-1">Save</.button>
        <.button
          :if={@page.slug != "home" && !is_nil(@page.id)}
          phx-click="delete"
          class="flex items-center justify-center !rounded"
        >
          <.icon name="hero-trash" class="w-4 h-4" />
        </.button>
      </div>
    </.form>
    """
  end
end
