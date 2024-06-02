defmodule SkullKing.Games.RoundUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "round_user"}

  @type t :: %__MODULE__{
          tricks_bid: integer(),
          tricks_won: integer() | nil,
          bid_points_won: integer() | nil,
          bonus_points_won: integer() | nil
        }
  schema "rounds_users" do
    field :tricks_bid, :integer
    field :tricks_won, :integer
    field :bid_points_won, :integer
    field :bonus_points_won, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    belongs_to :round, SkullKing.Games.Round, type: :string
    belongs_to :user, SkullKing.Games.GameUser, type: :string

    timestamps()
  end

  def changeset(round_user, params) do
    round = params.round

    round_user
    |> cast(params, [
      :tricks_bid,
      :tricks_won,
      :bid_points_won,
      :bonus_points_won,
      :game_id,
      :user_id
    ])
    |> validate_required([
      :tricks_bid,
      :game_id,
      :user_id
    ])
    |> put_assoc(:round, round)
    |> validate_number(:tricks_bid, less_than_or_equal_to: round.number)
    |> unique_constraint([:round_id, :user_id])
  end

  def score_changeset(round_user, params) do
    round_user
    |> cast(params, [
      :tricks_won,
      :bid_points_won,
      :bonus_points_won
    ])
    |> validate_required([
      :bid_points_won,
      :bonus_points_won,
      :tricks_won
    ])
  end
end
