defmodule CookieAuth.Repo.Migrations.AddCodeToAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      add :code, :string, null: false
    end
  end
end
