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

  @expire_time_in_seconds 60*60*24*30*12

  def validate_time(conn, auth) do
    expire_date = auth.inserted_at |> NaiveDateTime.add(@expire_time_in_seconds)
    NaiveDateTime.compare(expire_date, NaiveDateTime.utc_now()) == :gt
  end

  def verify_auth(conn) do
    if Map.has_key?(conn.cookies, "auth-cookie") do
      query = from a in Authentication, where: a.code == ^conn.cookies["auth-cookie"]
      auth = Repo.one(query) |> Repo.preload(:user)

      if auth && auth.active && auth.ip == get_ip(conn) && auth.useragent == get_useragent(conn) && validate_time(conn, auth) do
        {:ok, auth.user}
      else
        {:error, "token is not valid."}
      end
    else
      {:error, "auth-cookie is not set."}
    end
  end

  def save_code_in_cookie(conn, code) do
    conn
    |> Plug.Conn.put_resp_cookie("auth-cookie", code, max_age: @expire_time_in_seconds)
    |> Plug.Conn.fetch_cookies()
  end

  def get_useragent(%Plug.Conn{req_headers: headers}) do
    {"user-agent", useragent} = Enum.find(headers, fn x -> x |> Tuple.to_list() |> List.first() == "user-agent" end)
    useragent
  end

  def get_ip(%Plug.Conn{remote_ip: ip}) do
    ip |> :inet_parse.ntoa |> to_string()
  end

  def login(conn, %User{id: id}) do
    # 1 - GENERATE A CODE
    code = :crypto.strong_rand_bytes(32) |> Base.encode64() |> binary_part(0, 32)
    # 2 - CREATE THE AUTH RECORD
    params = %{user_id: id, code: code, useragent: get_useragent(conn), ip: get_ip(conn)}

    case create_authentication(params) do
      {:ok, _record} ->
        # 3 - SAVE CODE TO COOKIE
        save_code_in_cookie(conn, code)

      {:error, _msg} ->
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

  def set_active_to_false(code) do
    query = from a in Authentication, where: a.code == ^code
    auth = Repo.one(query)
    auth = Ecto.Changeset.change auth, active: false

    Repo.update auth
  end

  def logout(conn) do
    Plug.Conn.delete_resp_cookie(conn, "auth-cookie")
  end
end
