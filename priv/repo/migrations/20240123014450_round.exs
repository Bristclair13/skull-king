defmodule SkullKing.Repo.Migrations.Round do
  use Ecto.Migration

  def change do
    create table(:rounds, primary_key: [type: :text]) do
      add :game_id, references(:games, type: :text), null: false
      add :number, :integer, null: false

      timestamps()
    end

    create unique_index(:rounds, [:game_id, :number])
  end
end
