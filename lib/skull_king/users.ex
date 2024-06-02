defmodule SkullKing.Users do
  import SkullKing.MockHelper

  alias SkullKing.Users.PirateNames
  alias SkullKing.Users.Storage
  alias SkullKing.Users.User

  mock SkullKing.Users.Storage

  @callback find_or_create(String.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create(google_id) do
    name = PirateNames.random_name()

    case Storage.get(google_id) do
      user when is_struct(user) -> {:ok, user}
      _error -> Storage.create(%{name: name, google_id: google_id})
    end
  end
end
