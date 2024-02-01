defmodule SkullKing.Users.Repo do
  alias SkullKing.Users.User
  alias SkullKing.Repo

  def get(google_id) do
    Repo.get_by(User, google_id: google_id)
  end

  def create(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
