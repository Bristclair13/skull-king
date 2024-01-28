defmodule SkullKing.Games.GameUser do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "game_user"}
  schema "games_users" do
    field :user_order, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    belongs_to :user, SkullKing.Users.User, type: :string

    timestamps()
  end
end
