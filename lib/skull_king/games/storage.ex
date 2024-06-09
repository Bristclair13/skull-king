defmodule SkullKing.Games.Storage do
  @behaviour __MODULE__
  alias SkullKing.Games.Game
  alias SkullKing.Games.GameUser
  alias SkullKing.Games.Round
  alias SkullKing.Games.RoundUser
  alias SkullKing.Games.Trick
  alias SkullKing.Repo
  alias SkullKing.Users.User

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Repo.get(Game, id)
    |> Repo.preload([:users, :game_users])
  end

  @callback get_by(Keyword.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_by(by) do
    case Repo.get_by(Game, by) do
      game when is_struct(game) ->
        {:ok, game}

      _error ->
        {:error, :game_not_found}
    end
  end

  @callback create() :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create() do
    join_code = for _n <- 1..10, into: "", do: <<Enum.random(~c"0123456789abcdef")>>

    %Game{}
    |> Game.changeset(%{join_code: join_code})
    |> Repo.insert()
  end

  @callback load_round_users(Round.t()) :: Round.t()
  def load_round_users(round) do
    Repo.preload(round, :round_users, force: true)
  end

  @callback add_user_to_game(User.t(), Game.t()) ::
              {:ok, GameUser.t()} | {:error, Ecto.Changeset.t()}
  def add_user_to_game(user, game) do
    game = Repo.preload(game, :users, force: true)
    user_order = length(game.users)

    %GameUser{}
    |> GameUser.changeset(%{user_id: user.id, game_id: game.id, user_order: user_order})
    |> Repo.insert()
  end

  @callback create_round(Game.t()) :: {:ok, Round.t()} | {:error, Ecto.Changeset.t()}
  def create_round(game) do
    game = Repo.preload(game, :rounds, force: true)
    round_number = length(game.rounds) + 1

    %Round{}
    |> Round.changeset(%{number: round_number, game_id: game.id})
    |> Repo.insert()
  end

  @callback create_round_user(map()) :: {:ok, RoundUser.t()} | {:error, Ecto.Changeset.t()}
  def create_round_user(params) do
    %RoundUser{}
    |> RoundUser.changeset(params)
    |> Repo.insert(
      on_conflict: {:replace, [:tricks_bid, :updated_at]},
      conflict_target: [:round_id, :user_id]
    )
  end

  @callback create_trick(map()) :: {:ok, Trick.t()} | {:error, Ecto.changeset()}
  def create_trick(params) do
    %Trick{}
    |> Trick.changeset(params)
    |> Repo.insert()
  end

  @callback update_round_user_score(RoundUser.t(), map()) ::
              {:ok, RoundUser.t()} | {:error, Ecto.Changeset.t()}
  def update_round_user_score(round_user, params) do
    round_user
    |> RoundUser.score_changeset(params)
    |> Repo.update()
  end

  @callback get_tricks_for_round(Round.t()) :: [Trick.t()]
  def get_tricks_for_round(round) do
    round
    |> Repo.preload(:tricks)
    |> Map.fetch!(:tricks)
  end
end
