defmodule AccTournamentWeb.QualifierScoreController do
  alias AccTournament.Qualifiers.Attempt
  alias AccTournament.Levels.BeatMap
  alias Plug.Conn
  alias AccTournament.Qualifiers
  alias AccTournament.Repo
  use AccTournamentWeb, :controller
  import Ecto.Query

  def list_attempts(conn, %{"map_id" => map_id}) do
    import Ecto.Query, only: [from: 2]
    {map_id, _} = map_id |> Integer.parse()
    %{current_user: user} = conn.assigns

    attempts =
      from(
        attempt in Qualifiers.Attempt,
        where:
          attempt.map_id == ^map_id and
            attempt.player_id == ^user.id,
        preload: [],
        select: attempt
      )
      |> Repo.all()

    conn
    |> render(:attempt_listing, attempts: attempts)
  end

  @page_size 10

  def leaderboard(conn, %{"hash" => hash, "difficulty" => diff} = args) do
    import Ecto.Query, only: [from: 2, subquery: 1]
    {page, _} = Integer.parse(args["page"] || "1")
    page = page - 1

    query =
      from b in BeatMap,
        left_join: a in assoc(b, :attempts),
        distinct: [a.map_id, a.player_id],
        where:
          b.hash == ^hash and
            b.difficulty == ^diff,
        where: not is_nil(a.score),
        order_by: [asc: a.map_id, asc: a.player_id, desc: a.score],
        select: a

    attempts =
      from(a in subquery(query),
        order_by: [desc: a.score],
        select: {dense_rank() |> over(partition_by: a.map_id, order_by: [desc: a.score]), a},
        preload: [:player, :map]
      )
      |> Repo.all()

    conn
    |> render(:leaderboard,
      attempts:
        attempts
        |> Enum.slice(@page_size * page, @page_size),
      count: length(attempts)
    )
  end

  @max_attempts 3

  def remaining_attempts(conn, %{"hash" => hash, "difficulty" => diff}) do
    current_user = conn.assigns.current_user

    beatmap =
      from(b in BeatMap,
        left_join: a in assoc(b, :attempts),
        on: a.map_id == b.id and a.player_id == ^current_user.id,
        where:
          b.hash == ^hash and
            b.difficulty == ^diff,
        preload: [attempts: a]
      )
      |> Repo.one()

    case beatmap do
      %BeatMap{attempts: attempts} ->
        conn
        |> render(:remaining_attempts,
          remaining_attempts: max(@max_attempts - length(attempts || []), 0)
        )

      _ ->
        conn |> resp(:not_found, "Map not found")
    end
  end

  def create_attempt(conn, _args) do
    import Ecto.Query, only: [from: 2]

    current_user = conn.assigns.current_user

    case conn.body_params do
      %{"song_hash" => hash, "difficulty" => diff} ->
        beatmap =
          from(b in BeatMap,
            left_join: a in assoc(b, :attempts),
            on: a.map_id == b.id and a.player_id == ^current_user.id,
            where:
              b.hash == ^hash and
                b.difficulty == ^diff,
            preload: [attempts: a]
          )
          |> Repo.one()

        case beatmap do
          %BeatMap{attempts: attempts} ->
            remaining_attempts = max(@max_attempts - length(attempts || []), 0)

            case remaining_attempts do
              0 ->
                conn
                |> put_status(:too_many_requests)
                |> render(:attempt_created,
                  attempt: nil,
                  remaining_attempts: 0
                )

              _ ->
                attempt =
                  %Attempt{
                    player_id: current_user.id,
                    map_id: beatmap.id
                  }
                  |> Repo.insert!(returning: true)

                conn
                |> render(:attempt_created,
                  attempt: attempt,
                  remaining_attempts: remaining_attempts - 1
                )
            end

          _ ->
            conn |> Conn.resp(:not_found, "Map not found")
        end

      _ ->
        conn
        |> Conn.resp(:bad_request, "Invalid request body")
    end
  end

  def submit_attempt(
        conn,
        %{"attempt_id" => attempt_id, "score" => score}
      )
      when is_integer(attempt_id) and is_integer(score) do
    attempt = Attempt |> Repo.get(attempt_id)
    current_user = conn.assigns.current_user
    current_user_id = current_user.id

    case attempt do
      %Attempt{score: nil, player_id: ^current_user_id, map_id: map_id} ->
        attempt |> Attempt.score_changeset(%{score: score}) |> Repo.update!()
        AccTournament.Qualifiers.AttemptWeighting.new(%{"map_id" => map_id}) |> Oban.insert()

        conn |> resp(:ok, "Score submitted")

      %Attempt{player_id: ^current_user_id} ->
        conn |> resp(:unauthorized, "Attempt already has a score")

      _ ->
        conn |> resp(:not_found, "Attempt not found")
    end
  end

  def submit_attempt(conn, _args) do
    conn |> resp(:bad_request, "Invalid body parameters")
  end
end
