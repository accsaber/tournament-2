defmodule AccTournamentWeb.Overlay.IntroLive do
  alias AccTournament.Repo
  alias AccTournament.Stream
  use AccTournamentWeb, :overlay_live_view
  use LiveVue

  def render(assigns) do
    ~H"""
    <div class="dots-container absolute inset-0">
      <div class="dots !text-white" />
    </div>

    <div class="flex gap-6 w-full h-full items-center justify-center flex-col text-3xl font-semibold">
      <img src={~p"/images/logo.png"} class="relative size-64 bob" />
      <.vue
        :if={@stream.start_time}
        v-component="Countdown"
        startTime={(NaiveDateTime.to_iso8601(@stream.start_time)) <> "Z"}
      />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    stream = Stream |> Repo.one!()
    {:ok, socket |> assign(stream: stream)}
  end
end
