defmodule AccTournamentWeb.UserLoginLive do
  alias ElixirSense.Log
  alias AccTournament.BeatleaderLogin
  use AccTournamentWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm px-4 mt-16">
      <.header class="text-center">
        Log in with BeatLeader
        <:subtitle>
          This is strongly recommended as it means you don't need to share your email.
        </:subtitle>
      </.header>
      <form action={BeatleaderLogin.get_login_uri()} method="get" class="mt-4">
        <input
          type="hidden"
          name="client_id"
          value={Application.fetch_env!(:acc_tournament, :beatleader_client_id)}
        />
        <input type="hidden" name="response_type" value="code" />
        <input type="hidden" name="scope" value="profile" />
        <input
          type="hidden"
          name="redirect_uri"
          value={AccTournamentWeb.OAuthLoginController.redirect_uri()}
        />
        <.button class="w-full">Log in with BeatLeader</.button>
      </form>
    </div>

    <div class="w-full max-w-[30rem] my-8 h-px bg-neutral-200 mx-auto" />
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
