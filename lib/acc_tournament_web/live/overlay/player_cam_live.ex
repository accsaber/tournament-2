defmodule AccTournamentWeb.PlayerCamLive do
  alias AccTournamentWeb.Endpoint
  alias AccTournament.Accounts.Binding
  alias AccTournament.Repo
  use AccTournamentWeb, :overlay_live_view

  def render(%{player: nil} = assigns) do
    ~H"""
    <div class="flex w-screen h-screen bg-neutral-900 items-center justify-center">
      Twitch not linked
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <iframe
      src={"https://player.twitch.tv/?channel=#{URI.encode(@player)}&parent=#{@host}"}
      class="absolute inset-0 w-screen h-screen"
    />

    <script src="https://embed.twitch.tv/embed/v1.js">
    </script>
    """
  end

  def mount(_params, _session, socket) do
    host =
      Application.fetch_env!(:acc_tournament, Endpoint)
      |> Keyword.get(:url)
      |> Keyword.get(:host)

    {:ok, socket |> assign(player: nil, host: host)}
  end

  def handle_params(%{"id" => cam}, _uri, socket) do
    import Ecto.Query, only: [from: 2]

    match =
      from(s in AccTournament.Stream,
        left_join: m in assoc(s, :current_match),
        limit: 1,
        preload: [current_match: [player_1: [:account_bindings], player_2: [:account_bindings]]]
      )
      |> Repo.one()

    player =
      case cam do
        "1" ->
          match.current_match.player_1

        "2" ->
          match.current_match.player_2

        _ ->
          nil
      end

    twitch_binding = player.account_bindings |> Enum.find(&(&1.service == :twitch))

    case twitch_binding do
      %Binding{username: u} ->
        {:noreply, socket |> assign(player: u)}

      _ ->
        {:noreply, socket}
    end
  end
end
