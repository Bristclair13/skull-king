defmodule SkullKing.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "game"}
  schema "games" do
    field :join_code, :string

    many_to_many :users, SkullKing.Users.User, join_through: "games_users"
    has_many :rounds, SkullKing.Games.Round

    timestamps()
  end

  def changeset(%__MODULE__{} = game, params) do
    game
    |> cast(params, [:join_code])
    |> validate_required([:join_code])
    |> unique_constraint([:join_code])
  end
end
