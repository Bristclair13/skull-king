defmodule SkullKing.Games.Repo do
  alias SkullKing.Games.Game
  alias SkullKing.Repo

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Repo.get(Game, id)
  end

  @callback create() :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create() do
    join_code = for _n <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>

    %Game{}
    |> Game.changeset(%{join_code: join_code})
    |> Repo.insert()
  end
end
