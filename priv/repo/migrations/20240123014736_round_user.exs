defmodule SkullKing.Repo.Migrations.RoundUser do
  use Ecto.Migration

  def change do
    create table(:rounds_users, primary_key: [type: :text]) do
      add :game_id, references(:games, type: :text), null: false
      add :round_id, references(:rounds, type: :text), null: false
      add :user_id, references(:users, type: :text), null: false
      add :tricks_bid, :integer, null: false
      add :tricks_won, :integer, null: false
      add :bid_points_won, :integer, null: false
      add :accumulated_score, :integer, null: false

      timestamps()
    end

    create unique_index(:rounds_users, [:round_id, :user_id])
  end
end
