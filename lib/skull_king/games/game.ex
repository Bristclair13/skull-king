defmodule SkullKing.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias SkullKing.Games.Game

  @primary_key {:id, UXID, autogenerate: true, prefix: "game"}
  schema "games" do
    field :join_code, :string

    many_to_many :users, SkullKing.Users.User, join_through: "games_users"
    has_many :rounds, SkullKing.Games.Round

    timestamps()
  end

  def changeset(%Game{} = game, params) do
    game
    |> cast(params, [:join_code, :user_id, :round_id])
    |> validate_required([:join_code, :user_id, :round_id])
    |> unique_constraint([:game_id, :join_code])
  end
end
