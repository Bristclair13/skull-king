defmodule SkullKing.Games do
  use Injexor, otp_app: :skull_king, inject: [SkullKing.Games.Storage]

  alias SkullKing.Games.State
  alias SkullKing.Games.Storage
  alias SkullKing.Users.User

  @callback get(String.t()) :: Game.t() | nil
  def get(id) do
    Storage.get(id)
  end

  @callback create(User.t()) :: {:ok, Game.t()} | {:error, Ecto.Changeset.t()}
  def create(user) do
    with {:ok, game} <- Storage.create(),
         {:ok, _game_user} <- Storage.add_user_to_game(user, game) do
      {:ok, game}
    end
  end

  @callback join_game(User.t(), String.t()) ::
              {:ok, Game.t()} | {:error, :game_not_found} | {:error, :unexpected_error}
  def join_game(user, join_code) do
    with {:ok, game} <- Storage.get_by(join_code: join_code),
         {:ok, _game_user} <- Storage.add_user_to_game(user, game) do
      {:ok, game}
    else
      {:error, :game_not_found} -> {:error, :game_not_found}
      _error -> {:error, :unexpected_error}
    end
  end

  def start_round(game) do
    with {:ok, round} <- Storage.create_round(game) do
      cards_dealt = SkullKing.Games.Deck.deal(round, game.users)

      first_user_id =
        if round.number == 1 do
          Enum.random(game.game_users).user_id
        else
          %{starting_user_id: last_starting_user_id} = State.get_game(game.id)
          next_user(game, last_starting_user_id)
        end

      state = %State.Game{
        bidding_complete: false,
        cards_played: [],
        cards: cards_dealt,
        current_user_id: first_user_id,
        round_complete: false,
        round: round,
        starting_user_id: first_user_id,
        trick_number: 1,
        version: :reset
      }

      State.update_game(game.id, state)
    end
  end

  def score_round(round) do
    tricks = Storage.get_tricks_for_round(round)

    Enum.each(round.round_users, fn round_user ->
      tricks_bid = round_user.tricks_bid

      tricks_won =
        Enum.filter(tricks, fn trick ->
          trick.winning_user_id == round_user.user_id
        end)

      {bid_points_won, bonus_points_won} =
        cond do
          tricks_bid == 0 and Enum.empty?(tricks_won) ->
            {round.number * 10, 0}

          tricks_bid == 0 ->
            {round.number * -10, 0}

          tricks_bid == length(tricks_won) ->
            bonus_points = tricks_won |> Enum.map(& &1.bonus_points) |> Enum.sum()
            {tricks_bid * 20, bonus_points}

          true ->
            points_lost = abs(length(tricks_won) - tricks_bid) * -10
            {points_lost, 0}
        end

      Storage.update_round_user_score(round_user, %{
        tricks_won: length(tricks_won),
        bid_points_won: bid_points_won,
        bonus_points_won: bonus_points_won
      })
    end)
  end

  def save_bid(game, round, user, bid) do
    state = State.get_game(game.id)

    unless state.bidding_complete do
      {:ok, _round_user} =
        Storage.create_round_user(%{
          game_id: game.id,
          user_id: user.id,
          tricks_bid: bid,
          round: round
        })

      round = Storage.load_round_users(round)
      bidding_complete = length(game.game_users) == length(round.round_users)
      new_state = %{state | round: round, bidding_complete: bidding_complete}

      with {:error, :version_mismatch} <- State.update_game(game.id, new_state) do
        save_bid(game, round, user, bid)
      end
    end
  end

  def save_trick(game, winning_user_id, bonus_points) do
    %{trick_number: trick_number, round: round} = State.get_game(game.id)

    Storage.create_trick(%{
      bonus_points: bonus_points,
      game_id: game.id,
      round_id: round.id,
      winning_user_id: winning_user_id,
      number: trick_number
    })
  end

  def next_user(game, current_user_id) do
    game_users = Enum.sort_by(game.game_users, & &1.user_order)
    current_index = Enum.find_index(game_users, &(&1.user_id == current_user_id))
    next_user = Enum.at(game_users, current_index + 1, List.first(game_users))
    next_user.user_id
  end
end
