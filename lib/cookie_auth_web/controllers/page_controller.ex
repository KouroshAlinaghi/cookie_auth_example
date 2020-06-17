defmodule CookieAuthWeb.PageController do
  use CookieAuthWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
