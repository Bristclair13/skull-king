defmodule SkullKing.Games do
  alias SkullKing.Games.Repo
  alias SkullKing.Games.State
  alias SkullKing.Users.User

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
      first_user_id = Enum.random(game.game_users).user_id

      info = %{
        round: round,
        cards: cards_dealt,
        current_user_id: first_user_id,
        cards_played: [],
        bidding_complete: false
      }

      State.update_game(game.id, info)

      Phoenix.PubSub.broadcast(
        SkullKing.PubSub,
        game.id,
        {:round_started, info}
      )
    end
  end

  def save_bid(game, round, user, bid) do
    {:ok, _round_user} =
      Repo.create_round_user(%{
        game_id: game.id,
        user_id: user.id,
        tricks_bid: bid,
        round: round
      })

    Phoenix.PubSub.broadcast(
      SkullKing.PubSub,
      game.id,
      :submitted_bid
    )
  end

  def next_user(game, current_user_id) do
    game_users = Enum.sort_by(game.game_users, & &1.user_order)
    current_index = Enum.find_index(game_users, &(&1.user_id == current_user_id))
    next_user = Enum.at(game_users, current_index + 1, List.first(game_users))
    next_user.user_id
  end
end
