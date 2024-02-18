defmodule SkullKing.Users.Repo do
  alias SkullKing.Users.User
  alias SkullKing.Repo

  @callback get(String.t()) :: User.t() | nil
  def get(google_id) do
    Repo.get_by(User, google_id: google_id)
  end

  @callback create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
