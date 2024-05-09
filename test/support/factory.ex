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
end
