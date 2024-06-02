defmodule SkullKing.Factory do
  use ExMachina.Ecto, repo: SkullKing.Repo

  alias SkullKing.Users.PirateNames

  def user_factory() do
    %SkullKing.Users.User{
      id: UXID.generate!(prefix: "users"),
      name: PirateNames.random_name(),
      google_id: Ecto.UUID.generate()
    }
  end

  def round_factory() do
    %SkullKing.Games.Round{
      id: UXID.generate!(prefix: "round"),
      number: 1
    }
  end

  def round_user_factory() do
    %SkullKing.Games.RoundUser{
      id: UXID.generate(prefix: "round_user"),
      tricks_bid: 0
    }
  end

  def game_factory() do
    join_code = for _n <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>

    %SkullKing.Games.Game{
      id: UXID.generate!(prefix: "game"),
      join_code: join_code
    }
  end

  def trick_factory() do
    %SkullKing.Games.Trick{
      bonus_points: 0,
      number: 1
    }
  end
end
