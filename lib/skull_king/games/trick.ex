defmodule SkullKing.Games.Trick do
  use Ecto.Schema
  import Ecto.Changeset
  alias SkullKing.Games.Trick

  @primary_key {:id, UXID, autogenerate: true, prefix: "trick"}

  @type t :: %__MODULE__{
          bonus_points: integer()
        }

  schema "tricks" do
    field :bonus_points, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    belongs_to :round, SkullKing.Games.Round, type: :string
    belongs_to :winning_user, SkullKing.Users.User, type: :string

    timestamps()
  end

  def changeset(%Trick{} = trick, params) do
    trick
    |> cast(params, [:bonus_points, :game_id, :round_id, :winning_user_id])
    |> validate_required([:bonus_points, :game_id, :round_id, :winning_user_id])
    |> unique_constraint([:round_id, :game_id])
  end
end
