defmodule SkullKing.Games.Repo do
  alias SkullKing.Games.GameUser
  alias SkullKing.Games.Game
  alias SkullKing.Games.Round
  alias SkullKing.Repo

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Repo.get(Game, id)
    |> Repo.preload([:users, :game_users])
  end

  @callback get_by(Keyword.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_by(by) do
    case Repo.get_by(Game, by) do
      game when is_struct(game) -> {:ok, game}
      _error -> {:error, :game_not_found}
    end
  end

  @callback create() :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create() do
    join_code = for _n <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>

    %Game{}
    |> Game.changeset(%{join_code: join_code})
    |> Repo.insert()
  end

  def add_user_to_game(user, game) do
    game = Repo.preload(game, :users, force: true)
    user_order = length(game.users)

    %GameUser{}
    |> GameUser.changeset(%{user_id: user.id, game_id: game.id, user_order: user_order})
    |> Repo.insert()
  end

  def create_round(game) do
    game = Repo.preload(game, :rounds, force: true)
    round_number = length(game.rounds) + 1

    %Round{}
    |> Round.changeset(%{number: round_number, game_id: game.id})
    |> Repo.insert()
  end
end
