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
    belongs_to :round, SkullKing.Games.RoundUser, type: :string
    belongs_to :user, SkullKing.Games.GameUser, type: :string

    timestamps()
  end
end
