defmodule CookieAuth.Repo.Migrations.RemoveUserIdFromAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      remove :user_id
    end
  end
end
