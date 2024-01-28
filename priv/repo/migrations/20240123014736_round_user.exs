defmodule SkullKing.Repo.Migrations.RoundUser do
  use Ecto.Migration

  def change do
    create table(:rounds_users, primary_key: [type: :text]) do
      add :game_id, references(:games, type: :text), null: false
      add :round_id, references(:rounds, type: :text), null: false
      add :user_id, references(:users, type: :text), null: false
      add :tricks_bid, :integer
      add :tricks_won, :integer
      add :bid_points_won, :integer
      add :accumulated_score, :integer

      timestamps()
    end

    create unique_index(:rounds_users, [:round_id, :user_id])
  end
end
