defmodule SkullKing.Games.Trick do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "trick"}
  schema "tricks" do
    field :bonus_points, :integer

    belongs_to :game, SkullKing.Games.Game, type: :string
    belongs_to :round, SkullKing.Games.Round, type: :string
    belongs_to :winning_user, SkullKing.Users.User, type: :string

    timestamps()
  end
end
