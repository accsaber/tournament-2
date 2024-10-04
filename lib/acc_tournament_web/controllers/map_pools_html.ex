defmodule AccTournamentWeb.MapPoolsHTML do
  use AccTournamentWeb, :html

  defp diff_name(1), do: "Easy"
  defp diff_name(3), do: "Normal"
  defp diff_name(5), do: "Hard"
  defp diff_name(7), do: "Expert"
  defp diff_name(9), do: "Expert+"
  defp diff_name(id), do: id |> Integer.to_string()

  def filename(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
  end

  def listing(%{pools: _} = assigns) do
    ~H"""
    <div class="flex flex-col gap-4 bg-padding-bg gap-10 rounded p-4 prose max-w-none dark:prose-invert">
      <div :for={pool <- @pools} class="flex items-center gap-4">
        <div class="text-lg">
          <%= pool.name %>
        </div>
        <div>
          <div class="flex gap-2 flex-wrap">
            <img
              :for={map <- pool.beat_maps}
              class="h-8 m-0"
              src={"https://cdn.beatsaver.com/#{String.downcase(map.hash)}.jpg"}
            />
          </div>
        </div>
        <div class="ml-auto">
          <.link navigate={~p"/map_pools/#{pool.id}"}>View maps</.link>
        </div>
      </div>
    </div>
    """
  end

  def listing(%{pool: _, maps: _} = assigns) do
    ~H"""
    <.header>
      <%= @pool.name %>
      <:subtitle>
        <a
          href={~p"/api/map_pools/#{@pool.id}/playlist"}
          download={"acc-#{filename(@pool.name)}.bplist"}
          class={[
            "rounded bg-neutral-800 hover:bg-neutral-700 py-1.5 px-3",
            "text-sm font-semibold leading-6 text-white flex gap-2 items-center w-fit"
          ]}
        >
          <.icon name="hero-arrow-down-tray-mini" /> Download Playlist
        </a>
      </:subtitle>
    </.header>
    <div class="prose max-w-none dark:prose-invert mt-4">
      <table>
        <thead>
          <tr>
            <th>Song Name</th>
            <th>Artist</th>
            <th>Mapper</th>
            <th>Difficulty</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={map <- @maps}>
            <td><%= map.name %></td>
            <td><%= map.artist %></td>
            <td><%= map.mapper %></td>
            <td><%= diff_name(map.difficulty) %></td>
            <td>
              <a href={"https://beatsaver.com/maps/#{map.beatsaver_id}"}>
                !bsr <%= map.beatsaver_id %>
              </a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
