defmodule CookieAuth.Repo.Migrations.AddUserIdToAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end
    create index(:authentications, [:user_id])
  end
end
