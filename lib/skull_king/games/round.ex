defmodule SkullKing.Games.Round do
  use Ecto.Schema
  import Ecto.Changeset
  alias SkullKing.Games.Round

  @primary_key {:id, UXID, autogenerate: true, prefix: "round"}
  schema "rounds" do
    field :number, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string

    timestamps()
  end

  def changeset(%Round{} = round, params) do
    round
    |> cast(params, [:number, :game_id])
    |> validate_required([:number, :game_id])
    |> unique_constraint([:number, :game_id])
  end
end
