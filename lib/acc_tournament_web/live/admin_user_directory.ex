defmodule AccTournamentWeb.AdminUserDirectory do
  alias AccTournament.Accounts.User
  alias AccTournament.Repo
  alias AccTournament.Accounts
  use AccTournamentWeb, :live_view

  def render(assigns) do
    ~H"""
    <.table rows={@users} id="user-listing">
      <:col :let={player} label="Player">
        <.link navigate={"#{player}"} class="flex gap-2 items-center relative font-semibold underline">
          <img src={User.public_avatar_url(player)} class="h-6 w-6 rounded-full absolute" />
          <div class="w-full ml-8">
            <%= player.display_name %>
          </div>
        </.link>
      </:col>
      <:col :let={user} label="Email"><%= user.email %></:col>
      <:col :let={user} label="Roles"><%= inspect(user.roles) %></:col>
      <:col :let={user} label="Slug"><%= user.slug %></:col>
      <:col :let={user} label="Signup Date">
        <local-datetime><%= user.inserted_at %></local-datetime>
      </:col>
      <:action :let={user}>
        <.link navigate={user |> String.Chars.to_string()}>Profile</.link>
      </:action>
    </.table>
    """
  end

  def mount(_params, _session, socket) do
    users = Accounts.User |> Repo.all()
    {:ok, socket |> assign(page_title: "Admin - User Directory", users: users)}
  end
end
