defmodule AccTournament.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :slug, :string
    field :email, :string
    field :avatar_url, :string
    field :avatar_sizes, {:array, :string}
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    field :roles, {:array, Ecto.Enum},
      default: [],
      values: [:staff, :player, :coordinator, :map_pooler, :caster]

    field :pronouns, :string
    field :headset, :string
    field :bio, :string

    field :average_weight, :float

    has_many :account_bindings, AccTournament.Accounts.Binding

    has_many :attempts, AccTournament.Qualifiers.Attempt,
      foreign_key: :player_id,
      preload_order: [desc: :weight, desc: :score]

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:display_name, :email, :password, :avatar_url])
    |> validate_email(opts)
    |> validate_password(opts)
    |> validate_display_name(opts)
  end

  defp validate_display_name(changeset, _opts) do
    changeset
    |> validate_required([:display_name])
    |> validate_length(:display_name, min: 3, max: 16)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, AccTournament.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing their display name.

  """
  def display_name_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:display_name])
    |> validate_display_name(opts)
  end

  @doc """
  A user changeset for changing their average weight.

  It requires the name to change otherwise an error is added.
  """
  def average_weight_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:average_weight])
  end

  @doc """
  A user changeset for changing player's headset.
  """
  def headset_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:headset])
    |> validate_headset(opts)
  end

  @doc """
  A user changeset for changing pronuns.
  """
  def pronouns_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:pronouns])
    |> validate_pronouns(opts)
  end

  @doc """
  A user changeset for changing the bio
  """
  def bio_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:bio])
    |> validate_bio(opts)
  end

  @doc """
  A user changeset for changing the avatar
  """
  def avatar_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:avatar_url, :avatar_sizes])
  end

  defp validate_pronouns(changeset, _opts) do
    changeset
    |> validate_required([:pronouns])
    |> validate_format(:pronouns, ~r/^[a-zA-Z]+\/[a-zA-Z]+$/,
      message: "must be in the form of a/b"
    )
    |> validate_length(:pronouns, min: 3)
    |> validate_length(:pronouns, max: 32)
  end

  defp validate_headset(changeset, _opts) do
    changeset
    |> validate_required([:headset])
    |> validate_length(:headset, min: 3)
    |> validate_length(:headset, max: 32)
  end

  defp validate_bio(changeset, _opts) do
    changeset
    |> validate_length(:bio, max: 2048)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%AccTournament.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  def ingame_avatar_url(%__MODULE__{avatar_url: avatar}), do: ingame_avatar_url(avatar)

  def ingame_avatar_url("upload:" <> path),
    do:
      URI.append_path(
        Application.fetch_env!(:acc_tournament, :uploads_prefix),
        "/" <> path <> "@ingame.jpg"
      )
      |> URI.to_string()

  def ingame_avatar_url(path), do: path

  def public_avatar_url(user, size \\ nil)

  def public_avatar_url(%__MODULE__{avatar_url: "https://" <> _path = url}, _size), do: url

  def public_avatar_url(%__MODULE__{avatar_url: "upload:" <> path}, size) do
    path =
      if size do
        "/#{path}@#{size}.webp"
      else
        "/#{path}.webp"
      end

    URI.append_path(Application.fetch_env!(:acc_tournament, :uploads_prefix), path)
    |> URI.to_string()
  end

  def public_avatar_url(%__MODULE__{email: email}, _size) do
    "https://accsaber.com/api/avatar/#{email |> :erlang.md5() |> Base.encode16() |> String.downcase()}?d=blank"
  end

  def sanitised_display_name(%AccTournament.Accounts.User{display_name: display_name}) do
    sanitised_display_name(display_name)
  end

  def sanitised_display_name("" <> name) do
    name |> String.replace(~r/[^a-zA-Z0-9-_.~]+/, "")
  end
end

defimpl Phoenix.HTML.Safe, for: AccTournament.Accounts.User do
  def to_iodata(user) do
    String.Chars.to_string(user)
  end
end

defimpl String.Chars, for: AccTournament.Accounts.User do
  def to_string(%AccTournament.Accounts.User{display_name: display_name, slug: slug}) do
    "/profile/#{slug}/@#{AccTournament.Accounts.User.sanitised_display_name(display_name)}"
  end
end
