defmodule AccTournament.BeatleaderLogin do
  alias AccTournament.Accounts.User
  alias AccTournament.Accounts.Binding
  alias AccTournament.Repo

  import Ecto.Query, only: [from: 2]

  def get_login_uri do
    query = %{
      "client_id" => Application.fetch_env!(:acc_tournament, :beatleader_client_id),
      "response_type" => "code",
      "scope" => "profile",
      "redirect_uri" => "https://bseuc.eu/auth/callback/beatleader"
    }

    URI.parse("https://api.beatleader.xyz/oauth2/authorize")
    |> Map.put(
      :query,
      URI.encode_query(query)
    )
    |> URI.to_string()
  end

  def get_user_by_identity(%{"id" => platform_id}) do
    {platform_id, _} = Integer.parse(platform_id)

    connection =
      from b in Binding,
        where:
          b.service == :beatleader and
            b.platform_id ==
              ^platform_id,
        preload: [:user]

    binding = Repo.one(connection)

    case binding do
      %{user: user} -> user
      _ -> nil
    end
  end

  defp generate_random_password(),
    do: for(_ <- 1..72, into: "", do: <<Enum.random(~c"0123456789abcdef")>>)

  def create_user_from_beatleader_profile(%{"id" => id, "name" => username}) do
    {int_id, _} = Integer.parse(id)

    {:ok, result} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        User,
        %User{
          confirmed_at: NaiveDateTime.local_now()
        }
        |> User.registration_changeset(%{
          display_name: username,
          password: generate_random_password(),
          email: id <> "@beatleader"
        })
      )
      |> Ecto.Multi.run(
        Binding,
        fn repo, %{User => user} ->
          repo.insert(%Binding{
            service: :beatleader,
            platform_id: int_id,
            user_id: user.id
          })
        end
      )
      |> Repo.transaction()

    result[User]
  end
end

defmodule AccTournament.BeatleaderLogin.NotLoggedIn do
  defexception message: "Invalid BeatLeader auth token", plug_status: 401, body: %{}
end
