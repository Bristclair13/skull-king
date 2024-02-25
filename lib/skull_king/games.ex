defmodule SkullKing.Games do
  alias SkullKing.Games.Repo

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Repo.get(id)
  end

  @callback create() :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create() do
    Repo.create()
  end
end
