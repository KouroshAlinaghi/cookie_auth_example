defmodule CookieAuth.Repo.Migrations.AddIpAndUseragentToAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      add :ip, :string, null: false
      add :useragent, :string, null: false
    end
  end
end
