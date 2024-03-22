defmodule SkullKing.Games do
  alias SkullKing.Users.User
  alias SkullKing.Games.Repo

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Repo.get(id)
  end

  @callback get_by(Keyword.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_by(by) do
    Repo.get_by(by)
  end

  @callback create(User.t()) :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create(user) do
    with {:ok, game} <- Repo.create(),
         {:ok, _game_user} <- Repo.add_user_to_game(user, game) do
      {:ok, game}
    end
  end

  @callback join_game(User.t(), String.t()) ::
              {:ok, Game.t()} | {:error, :game_not_found} | {:error, :unexpected_error}
  def join_game(user, join_code) do
    with {:ok, game} <- get_by(join_code: join_code),
         {:ok, _game_user} <- Repo.add_user_to_game(user, game) do
      {:ok, game}
    else
      {:error, :game_not_found} -> {:error, :game_not_found}
      _error -> {:error, :unexpected_error}
    end
  end

  def start_round(game) do
    with {:ok, round} <- Repo.create_round(game) do
      cards_dealt = SkullKing.Games.Deck.deal(round, game.users)

      Phoenix.PubSub.broadcast(
        SkullKing.PubSub,
        game.id,
        {:round_started,
         %{
           number: round.number,
           cards: cards_dealt
         }}
      )
    end
  end
end
