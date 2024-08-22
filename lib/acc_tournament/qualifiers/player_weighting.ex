defmodule AccTournament.Qualifiers.PlayerWeighting do
  alias AccTournament.Accounts.User
  alias AccTournament.Repo
  alias AccTournament.Qualifiers.Attempt
  use Oban.Worker
  import Ecto.Query, only: [from: 2, subquery: 1]

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    attempts =
      from(a in Attempt,
        distinct: [a.map_id, a.player_id],
        where: not is_nil(a.score),
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score]
      )

    attempts =
      from(a in subquery(attempts),
        order_by: [desc: a.score],
        select: {dense_rank() |> over(partition_by: a.map_id, order_by: [desc: a.score]), a},
        preload: [:player]
      )

    {:ok, r} =
      Ecto.Multi.new()
      |> Ecto.Multi.all(:players, User)
      |> Ecto.Multi.all(:attempts, attempts)
      |> Repo.transaction()

    Repo.transaction(fn ->
      for player <- r.players do
        id = player.id

        attempts =
          for {_, %Attempt{player_id: ^id} = attempt} <- r.attempts, do: attempt

        weights = for attempt <- attempts, do: attempt.weight

        n = length(weights)

        weights =
          if n < 3 do
            padding =
              Stream.cycle([25])
              |> Enum.take(3 - n)

            weights ++ padding
          else
            weights
          end

        average_weight = Enum.reduce(weights, &(&1 + &2)) / 3

        User.average_weight_changeset(player, %{average_weight: average_weight})
        |> Repo.update!()
      end
    end)

    :ok
  end
end
