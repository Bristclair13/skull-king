defmodule SkullKing.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UXID, autogenerate: true, prefix: "game"}

  @type t :: %__MODULE__{
          join_code: integer()
        }

  schema "games" do
    field :join_code, :string

    has_many :rounds, SkullKing.Games.Round
    has_many :game_users, SkullKing.Games.GameUser
    has_many :users, through: [:game_users, :user]

    timestamps()
  end

  def changeset(%__MODULE__{} = game, params) do
    game
    |> cast(params, [:join_code])
    |> validate_required([:join_code])
    |> unique_constraint([:join_code])
  end
end
