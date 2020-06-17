defmodule CookieAuth.Accounts.Authentication do
  use Ecto.Schema
  import Ecto.Changeset

  alias CookieAuth.Accounts.User

  schema "authentications" do
    field :code, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(authentication, attrs) do
    authentication
    |> cast(attrs, [:code, :user_id])
    |> validate_required([:code, :user_id])
  end
end
