defmodule SkullKing.Repo.Migrations.Game do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: [type: :text]) do
      add(:join_code, :text)

      timestamps()
    end

    create unique_index(:games, :join_code)
  end
end
