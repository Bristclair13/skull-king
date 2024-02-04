defmodule SkullKing.Games.GameUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias SkullKing.Games.GameUser

  @type t :: %__MODULE__{
          user_order: integer()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "game_user"}
  schema "games_users" do
    field :user_order, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    belongs_to :user, SkullKing.Users.User, type: :string

    timestamps()
  end

  def changeset(%GameUser{} = game_user, params) do
    game_user
    |> cast(params, [:user_order, :game_id, :user_id])
    |> validate_required([:user_order, :game_id, :user_id])
    |> unique_constraint([:game_id, :user_id])
  end
end
