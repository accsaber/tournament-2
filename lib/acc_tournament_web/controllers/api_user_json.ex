defmodule AccTournamentWeb.ApiUserJSON do
  alias AccTournament.Accounts.User

  def user_basic(%{conn: conn}) do
    user = conn.assigns.current_user

    %{
      display_name: user.display_name,
      avatar_url: User.public_avatar_url(user),
      slug: user.slug,
      qualifier_seed: -1
    }
  end
end
