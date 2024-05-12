defmodule SkullKing.Repo.Migrations.AddNumberToTrick do
  use Ecto.Migration

  def change do
    alter table(:tricks) do
      add :number, :integer
    end
  end
end
