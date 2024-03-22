defmodule SkullKing.Repo.Migrations.GameUser do
  use Ecto.Migration

  def change do
    create table(:games_users, primary_key: [type: :text]) do
      add :game_id, references(:games, type: :text), null: false
      add :user_id, references(:users, type: :text), null: false

      add :user_order, :integer, null: false

      timestamps()
    end

    create unique_index(:games_users, [:game_id, :user_id])
  end
end
