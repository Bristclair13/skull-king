defmodule SkullKing.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: [type: :text]) do
      add :name, :text, null: false
      add :google_id, :text, null: false

      timestamps()
    end

    create unique_index(:users, [:google_id])
  end
end
