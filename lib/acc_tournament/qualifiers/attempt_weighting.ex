defmodule AccTournament.Qualifiers.AttemptWeighting do
  alias AccTournament.Repo
  alias AccTournament.Qualifiers.Attempt
  alias AccTournament.Levels.BeatMap
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"map_id" => map_id}
      }) do
    import Ecto.Query, only: [from: 2, subquery: 1]

    query =
      from b in BeatMap,
        left_join: a in assoc(b, :attempts),
        distinct: [a.map_id, a.player_id],
        where: b.id == type(^map_id, :integer),
        where: not is_nil(a.score),
        where: b.map_pool_id == 1,
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score],
        select: a

    attempts =
      from(a in subquery(query),
        order_by: [desc: a.score],
        select: a,
        preload: [:player, :map]
      )
      |> Repo.all()

    {max_score, first_delta, map} =
      case attempts do
        [first | _] ->
          max_score = first.map.max_score || 1
          first_delta = max_score - first.score

          {max_score, first_delta, first.map}

        [] ->
          {nil, nil, nil}
      end

    unless is_nil(max_score) do
      attempts =
        Repo.transaction(fn ->
          for attempt <- attempts do
            attempt
            |> Attempt.weight_changeset(%{weight: (max_score - attempt.score) / first_delta})
            |> Repo.update()
          end
        end)

      Phoenix.PubSub.broadcast(AccTournament.PubSub, "leaderboard_updated", {:map, map.id})

      AccTournament.Qualifiers.PlayerWeighting.new(%{}) |> Oban.insert()
      {:ok, attempts}
    else
      :ok
    end
  end
end
