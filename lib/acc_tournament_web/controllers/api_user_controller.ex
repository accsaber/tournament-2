defmodule AccTournamentWeb.ApiUserController do
  use AccTournamentWeb, :controller
  import Ecto.Query, only: [from: 2, subquery: 1]
  alias AccTournament.{Repo, Accounts.User}

  def whoami(conn, _args) do
    ranked_users =
      from(
        u in User,
        select: %{rank: rank() |> over(order_by: [desc: u.average_weight]), id: u.id},
        where: u.average_weight > ^0
      )

    rank =
      Ecto.Query.from(
        u in subquery(ranked_users),
        where: u.id == ^conn.assigns.current_user.id
      )
      |> Repo.one()
      |> case do
        %{rank: rank} ->
          rank

        _ ->
          nil
      end

    conn |> render(:user_basic, player: conn.assigns.current_user, rank: rank)
  end
end
