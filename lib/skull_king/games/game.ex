defmodule SkullKing.Games.Game do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "game"}
  schema "games" do
    field :join_code, :string

    many_to_many :users, SkullKing.Users.User, join_through: "games_users"
    has_many :rounds, SkullKing.Games.Round

    timestamps()
  end
end
