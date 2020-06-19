defmodule CookieAuth.Accounts.Authentication do
  use Ecto.Schema
  import Ecto.Changeset

  alias CookieAuth.Accounts.User

  schema "authentications" do
    field :code, :string
    field :useragent, :string
    field :active, :boolean
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(authentication, attrs) do
    authentication
    |> cast(attrs, [:code, :user_id, :useragent])
    |> validate_required([:code, :user_id, :useragent])
  end
end
