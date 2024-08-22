defmodule AccTournamentWeb.QualifierScoreJSON do
  alias AccTournament.Accounts.User

  def attempt_listing(%{conn: %Plug.Conn{assigns: %{attempts: attempts}}}) do
    %{
      used_attempts: length(attempts),
      attempts: attempts
    }
  end

  def attempt_created(%{remaining_attempts: remaining_attempts, attempt: attempt}) do
    %{
      remaining_attempts: remaining_attempts,
      attempt_id: if(attempt, do: attempt.id),
      attempt: attempt
    }
  end

  def remaining_attempts(%{remaining_attempts: remaining_attempts}) do
    %{
      remaining_attempts: remaining_attempts
    }
  end

  def leaderboard(%{attempts: attempts, count: count}) do
    %{
      count: count,
      scores:
        for(
          {rank, attempt} <- attempts,
          do: %{
            rank: rank,
            username: attempt.player.display_name,
            weight: attempt.weight || 15,
            avatar_url: User.public_avatar_url(attempt.player),
            score: attempt.score
          }
        )
    }
  end
end
