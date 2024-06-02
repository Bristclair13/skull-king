defmodule SkullKing.Repo.Migrations.AddBonusPointsWon do
  use Ecto.Migration

  def change do
    alter table(:rounds_users) do
      add :bonus_points_won, :integer
    end
  end
end
