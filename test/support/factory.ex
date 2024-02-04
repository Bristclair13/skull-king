defmodule SkullKing.Factory do
  use ExMachina.Ecto, repo: SkullKing.Repo

  def user_factory() do
    %SkullKing.Users.User{
      # TODO: change to pirate name generator,
      name: "name",
      google_id: Ecto.UUID.generate()
    }
  end
end
