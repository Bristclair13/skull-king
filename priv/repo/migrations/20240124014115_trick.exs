defmodule SkullKing.Repo.Migrations.Trick do
  use Ecto.Migration

  def change do
    create table(:tricks, primary_key: [type: :text]) do
      add :game_id, references(:games, type: :text), null: false
      add :round_id, references(:rounds, type: :text), null: false
      add :winning_user_id, references(:users, type: :text), null: false
      add :bonus_points, :integer, null: false

      timestamps()
    end

    create unique_index(:tricks, [:round_id, :game_id])
  end
end
