defmodule CookieAuth.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias CookieAuth.Repo
  alias Argon2
  alias CookieAuth.Accounts.{User, Authentication}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def verify_credentials(email, password) do
    query = from u in User, where: u.email == ^email
    case Repo.one(query) do
      nil ->
        {:error, :invalid_credentials}
      user ->
        if Argon2.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def save_code_in_cookie(conn, code) do
    conn
    |> Plug.Conn.put_resp_cookie("auth-cookie", code)
    |> Plug.Conn.fetch_cookies()
  end

  def login(conn, %User{id: id}) do
    # 1 - GENERATE A CODE
    code = :crypto.strong_rand_bytes(32) |> Base.encode64 |> binary_part(0, 32)
    # 2 - CREATE THE AUTH RECORD
    params = %{user_id: id, code: code}
    case create_authentication(params) do
      {:ok, record} ->
        # 3 - SAVE CODE TO SESSION
        save_code_in_cookie(conn, code)
      {:error, msg} ->
        conn
    end
  end

  def list_authentications() do
    Authentication
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def create_authentication(attrs \\ %{}) do
    %Authentication{}
    |> Authentication.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_code(code) do
    query = from a in Authentication, where: a.code == ^code
    auth = query
    |> Repo.one()
    |> Repo.preload(:user)
    auth.user
  end

end
