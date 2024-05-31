defmodule AccTournament.Repo do
  use Ecto.Repo,
    otp_app: :acc_tournament,
    adapter: Ecto.Adapters.Postgres
end
