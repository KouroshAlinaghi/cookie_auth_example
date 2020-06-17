defmodule CookieAuth.Repo.Migrations.CreateAuthentications do
  use Ecto.Migration

  def change do
    create table(:authentications) do
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:authentications, [:user_id])
  end
end
