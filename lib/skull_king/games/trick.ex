defmodule SkullKing.Games.Trick do
  use Ecto.Schema

  @primary_key {:id, UXID, autogenerate: true, prefix: "trick"}
  schema "tricks" do
    field :winning_user_id, :string
    field :bonus_points, :integer

    belongs_to :games, SkullKing.Games.Game, type: :string
    belongs_to :rounds, SkullKing.Games.Round, type: :string

    timestamps()
  end
end
