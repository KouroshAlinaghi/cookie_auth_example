defmodule CookieAuth.Repo.Migrations.RemoveUsernameAndRoleFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :username
      remove :role
    end
  end
end
