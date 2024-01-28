defmodule SkullKing.Games.Round do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "round"}
  schema "rounds" do
    field :number, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string

    timestamps()
  end
end
