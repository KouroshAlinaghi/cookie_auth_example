defmodule CookieAuth.Repo.Migrations.RemoveIpFromAuthentications do
  use Ecto.Migration

  def change do
    alter table(:authentications) do
      remove :ip
    end
  end
end
