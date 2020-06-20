defmodule CookieAuthWeb.Router do
  use CookieAuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :check_auth do
    plug :auth_verify
  end

  pipeline :req_auth do
    plug :require_auth
  end

  pipeline :req_no_auth do
    plug :require_no_auth
  end

  def require_no_auth(conn, _params) do
    if Map.has_key?(conn.assigns, :current_user) do
      conn
      |> put_flash(:error, "require not auth")
      |> redirect(to: "/")
    else
      conn
    end
  end

  def require_auth(conn, _params) do
    if Map.has_key?(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_flash(:error, "require auth")
      |> redirect(to: "/")
    end
  end

  def auth_verify(conn, _params) do
    case CookieAuth.Accounts.verify_auth(conn) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> assign(:user_signed_in, true)
      {:error, :invalid_token} ->
        conn
        |> CookieAuth.Accounts.logout()
        |> assign(:user_signed_in, false)
      {:error, _} ->
        conn
        |> assign(:user_signed_in, false)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CookieAuthWeb do
    pipe_through [:browser, :check_auth, :req_auth]
    delete "logout", CookieController, :delete
    get "sessions", CookieController, :index
    delete "sessions/delete/:id", CookieController, :delete_session
    resources "users", UserController, only: [:delete]
  end

  scope "/", CookieAuthWeb do
    pipe_through [:browser, :check_auth, :req_no_auth]
    get "login", CookieController, :new
    post "login", CookieController, :create
    resources "users", UserController, only: [:new, :create]
  end

  scope "/", CookieAuthWeb do
    pipe_through [:browser, :check_auth]

    get "/", PageController, :index
    resources "users", UserController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", CookieAuthWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CookieAuthWeb.Telemetry
    end
  end
end
