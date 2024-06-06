defmodule SkullKing.Repo.Migrations.UpdateTrickUniqueIndex do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:tricks, [:round_id, :game_id])
    create_if_not_exists unique_index(:tricks, [:round_id, :game_id, :number])
  end
end
