defmodule CookieAuthWeb.CookieController do
  use CookieAuthWeb, :controller

  alias CookieAuth.Accounts
  alias CookieAuth.Accounts.User

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

  def delete(conn, _params) do
    Accounts.remove_auth_record(conn.cookies["auth-cookie"])

    conn
    |> Accounts.logout()
    |> put_flash(:info, "Loged out successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

end
