defmodule SkullKing.Users do
  import SkullKing.MockHelper

  alias SkullKing.Users.Repo
  alias SkullKing.Users.User

  mock SkullKing.Users.Repo

  @pirate_names [
    "William Kidd",
    "Blackbeard",
    "Bartholomew Roberts",
    "Henry Every",
    "Henry Morgan",
    "Stede Bonnet",
    "Thomas Tew",
    "Anne Bonny",
    "Bones",
    "Calico Jack",
    "Edward Low",
    "Howell Davis",
    "Samuel Bellamy",
    "Admiral",
    "Archer",
    "Augie",
    "Azure",
    "Bastian",
    "Belle",
    "Bertha",
    "Booty",
    "Captain",
    "Captain Jolly",
    "Caspian"
  ]

  @callback find_or_create(String.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create(google_id) do
    name = Enum.random(@pirate_names)

    case Repo.get(google_id) do
      user when is_struct(user) -> {:ok, user}
      _error -> Repo.create(%{name: name, google_id: google_id})
    end
  end
end
