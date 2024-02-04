defmodule SkullKing.Games.RoundUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias SkullKing.Games.RoundUser

  @primary_key {:id, UXID, autogenerate: true, prefix: "round_user"}

  @type t :: %__MODULE__{
          tricks_bid: integer(),
          tricks_won: integer(),
          bid_points_won: integer(),
          bonus_points_won: integer(),
          accumulated_score: integer()
        }
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

  def changeset(%RoundUser{} = round_user, params) do
    round_user
    |> cast(params, [
      :tricks_bid,
      :tricks_won,
      :bid_points_won,
      :bonus_points_won,
      :accumulated_score,
      :game_id,
      :round_id,
      :user_id
    ])
    |> validate_required([
      :tricks_bid,
      :tricks_won,
      :bid_points_won,
      :bonus_points_won,
      :accumulated_score,
      :game_id,
      :round_id,
      :user_id
    ])
    |> unique_constraint([:round_id, :user_id])
  end
end
