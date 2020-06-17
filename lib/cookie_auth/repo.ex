defmodule CookieAuth.Repo do
  use Ecto.Repo,
    otp_app: :cookie_auth,
    adapter: Ecto.Adapters.Postgres
end
