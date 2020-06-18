defmodule CookieAuth.Repo.Migrations.AddActiveToAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      add :active, :boolean, default: true, null: false
    end
  end
end
