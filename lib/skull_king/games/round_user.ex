defmodule SkullKing.Games.RoundUser do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "round_user"}
  schema "rounds_users" do
    field :tricks_bid, :integer
    field :tricks_won, :integer
    field :bid_points_won, :integer
    field :bonus_points_won, :integer
    field :accumulated_score, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    has_many :rounds, SkullKing.Games.RoundUser
    many_to_many :users, SkullKing.Games.GameUser, join_through: "game_users"

    timestamps()
  end
end
