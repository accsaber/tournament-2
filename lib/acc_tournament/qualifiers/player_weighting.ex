defmodule AccTournament.Qualifiers.PlayerWeighting do
  alias AccTournament.Accounts.User
  alias AccTournament.Repo
  alias AccTournament.Qualifiers.Attempt
  use Oban.Worker
  import Ecto.Query, only: [from: 2, subquery: 1]

  @counted_attempts 3

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    attempts =
      from(a in Attempt,
        distinct: [a.map_id, a.player_id],
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score]
      )

    attempts =
      from(a in subquery(attempts),
        order_by: [desc: a.score],
        where: not is_nil(a.weight),
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
          for %Attempt{player_id: ^id} = attempt <- r.attempts, do: attempt

        weights = for attempt <- attempts, do: attempt.weight

        padding =
          Stream.cycle([25])
          |> Enum.take(@counted_attempts)

        weights =
          (weights ++ padding)
          |> Enum.take(@counted_attempts)

        average_weight = Enum.reduce(weights, &(&1 + &2)) / @counted_attempts

        User.average_weight_changeset(player, %{average_weight: average_weight})
        |> Repo.update!()
      end
    end)

    :ok
  end
end
