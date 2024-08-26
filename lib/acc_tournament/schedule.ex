defmodule AccTournament.Schedule do
  @moduledoc """
  The Schedule context.
  """

  import Ecto.Query, warn: false
  alias AccTournament.Repo

  alias AccTournament.Schedule.Round

  @doc """
  Returns the list of rounds.

  ## Examples

      iex> list_rounds()
      [%Round{}, ...]

  """
  def list_rounds do
    Repo.all(Round)
  end

  @doc """
  Gets a single round.

  Raises `Ecto.NoResultsError` if the Round does not exist.

  ## Examples

      iex> get_round!(123)
      %Round{}

      iex> get_round!(456)
      ** (Ecto.NoResultsError)

  """
  def get_round!(id), do: Repo.get!(Round, id)

  @doc """
  Creates a round.

  ## Examples

      iex> create_round(%{field: value})
      {:ok, %Round{}}

      iex> create_round(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_round(attrs \\ %{}) do
    %Round{}
    |> Round.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a round.

  ## Examples

      iex> update_round(round, %{field: new_value})
      {:ok, %Round{}}

      iex> update_round(round, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_round(%Round{} = round, attrs) do
    round
    |> Round.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a round.

  ## Examples

      iex> delete_round(round)
      {:ok, %Round{}}

      iex> delete_round(round)
      {:error, %Ecto.Changeset{}}

  """
  def delete_round(%Round{} = round) do
    Repo.delete(round)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking round changes.

  ## Examples

      iex> change_round(round)
      %Ecto.Changeset{data: %Round{}}

  """
  def change_round(%Round{} = round, attrs \\ %{}) do
    Round.changeset(round, attrs)
  end

  alias AccTournament.Schedule.Match

  @doc """
  Returns the list of matches.

  ## Examples

      iex> list_matches()
      [%Match{}, ...]

  """
  def list_matches do
    Repo.all(Match)
  end

  @doc """
  Gets a single match.

  Raises `Ecto.NoResultsError` if the Match does not exist.

  ## Examples

      iex> get_match!(123)
      %Match{}

      iex> get_match!(456)
      ** (Ecto.NoResultsError)

  """
  def get_match!(id), do: Repo.get!(Match, id)

  @doc """
  Creates a match.

  ## Examples

      iex> create_match(%{field: value})
      {:ok, %Match{}}

      iex> create_match(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a match.

  ## Examples

      iex> update_match(match, %{field: new_value})
      {:ok, %Match{}}

      iex> update_match(match, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a match.

  ## Examples

      iex> delete_match(match)
      {:ok, %Match{}}

      iex> delete_match(match)
      {:error, %Ecto.Changeset{}}

  """
  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking match changes.

  ## Examples

      iex> change_match(match)
      %Ecto.Changeset{data: %Match{}}

  """
  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  alias AccTournament.Schedule.Pick

  @doc """
  Returns the list of picks.

  ## Examples

      iex> list_picks()
      [%Pick{}, ...]

  """
  def list_picks do
    Repo.all(Pick)
  end

  @doc """
  Gets a single pick.

  Raises `Ecto.NoResultsError` if the Pick does not exist.

  ## Examples

      iex> get_pick!(123)
      %Pick{}

      iex> get_pick!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pick!(id), do: Repo.get!(Pick, id)

  @doc """
  Creates a pick.

  ## Examples

      iex> create_pick(%{field: value})
      {:ok, %Pick{}}

      iex> create_pick(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pick(attrs \\ %{}) do
    %Pick{}
    |> Pick.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pick.

  ## Examples

      iex> update_pick(pick, %{field: new_value})
      {:ok, %Pick{}}

      iex> update_pick(pick, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pick(%Pick{} = pick, attrs) do
    pick
    |> Pick.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pick.

  ## Examples

      iex> delete_pick(pick)
      {:ok, %Pick{}}

      iex> delete_pick(pick)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pick(%Pick{} = pick) do
    Repo.delete(pick)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pick changes.

  ## Examples

      iex> change_pick(pick)
      %Ecto.Changeset{data: %Pick{}}

  """
  def change_pick(%Pick{} = pick, attrs \\ %{}) do
    Pick.changeset(pick, attrs)
  end
end
