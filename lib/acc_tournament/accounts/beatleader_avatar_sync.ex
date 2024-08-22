defmodule AccTournament.Accounts.BeatleaderAvatarSync do
  alias AccTournament.Accounts.Binding
  alias AccTournament.Accounts.User
  use Oban.Worker
  alias AccTournament.Repo

  import Ecto.Query, only: [preload: 2, where: 2]

  def perform(%Oban.Job{args: %{"beatleader_id" => beatleader_id}}) do
    binding =
      Binding
      |> where(platform_id: ^beatleader_id)
      |> where(service: :beatleader)
      |> preload(:user)
      |> Repo.one!()

    response =
      Req.get!("https://api.beatleader.xyz/player/#{beatleader_id}")

    case response do
      %Req.Response{status: 200, body: %{"avatar" => "" <> avatar}} ->
        User.avatar_changeset(binding.user, %{avatar_url: avatar})
        |> Repo.update!()

        :ok

      _ ->
        :ok
    end
  end
end
