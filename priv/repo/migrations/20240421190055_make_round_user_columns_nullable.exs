defmodule SkullKing.Repo.Migrations.MakeRoundUserColumnsNullable do
  use Ecto.Migration

  def change do
    alter table(:rounds_users) do
      modify :tricks_won, :integer, null: true
      modify :bid_points_won, :integer, null: true
      modify :accumulated_score, :integer, null: true
    end
  end
end
