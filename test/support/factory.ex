defmodule SkullKing.Factory do
  use ExMachina.Ecto, repo: SkullKing.Repo

  alias SkullKing.Users.PirateNames

  def user_factory() do
    %SkullKing.Users.User{
      name: PirateNames.random_name(),
      google_id: Ecto.UUID.generate()
    }
  end
end
