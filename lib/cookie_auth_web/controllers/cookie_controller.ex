defmodule CookieAuthWeb.CookieController do
  use CookieAuthWeb, :controller

  alias CookieAuth.Accounts
  alias CookieAuth.Accounts.User

  def index(conn, _params) do
    user_sessions = Accounts.list_active_sessions(conn.assigns.current_user)
    render(conn, "index.html", user_sessions: user_sessions)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, action: Routes.cookie_path(conn, :create))
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.verify_credentials(email, password) do
      {:ok, user} ->
        conn
        |> Accounts.login(user)
        |> put_flash(:info, "Login was done successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _} ->
        changeset = Accounts.change_user(%User{})

        conn
        |> put_flash(:error, "Credentials Are Not Valid.")
        |> render("new.html", changeset: changeset, action: Routes.cookie_path(conn, :create))
    end
  end

  def delete_session(conn, %{"id" => id}) do
    session = Accounts.get_session!(id)
    Accounts.set_active_to_false(session.code)

    conn
    |> put_flash(:info, "Session Unactived Successfully/")
    |> redirect(to: Routes.cookie_path(conn, :index))
  end

  def delete(conn, _params) do
    Accounts.set_active_to_false(conn.cookies["TOKEN"])

    conn
    |> Accounts.logout()
    |> put_flash(:info, "Loged out successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
