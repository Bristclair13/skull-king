defmodule SkullKing.Games.State do
  @behaviour __MODULE__

  defmodule Game do
    defstruct [
      :bidding_complete,
      :cards_played,
      :cards,
      :current_user_id,
      :last_trick_cards_played,
      :round_complete,
      :round,
      :starting_user_id,
      :trick_number,
      :version
    ]
  end

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:get_game, game_id}, _from, state) do
    game_info =
      Map.get(state, game_id, %Game{
        cards: %{},
        cards_played: [],
        current_user_id: nil,
        round: nil,
        bidding_complete: false,
        round_complete: false
      })

    {:reply, game_info, state}
  end

  def handle_call({:update_game, game_id, %Game{} = info}, _from, state) do
    update_version = info.version || 1

    current_version =
      case state[game_id] do
        %Game{version: version} -> version
        nil -> 1
      end

    if update_version == current_version or update_version == :reset do
      new_game_state = Map.put(info, :version, current_version + 1)
      new_state = Map.put(state, game_id, new_game_state)
      {:reply, {:ok, new_game_state}, new_state}
    else
      {:reply, {:error, :version_mismatch}, state}
    end
  end

  @callback get_game(String.t()) :: %Game{}
  def get_game(game_id) do
    GenServer.call(__MODULE__, {:get_game, game_id})
  end

  @callback update_game(String.t(), %Game{}) :: :ok | {:error, term()}
  def update_game(game_id, %Game{} = state) do
    case GenServer.call(__MODULE__, {:update_game, game_id, state}) do
      {:ok, new_game_state} ->
        Phoenix.PubSub.broadcast(
          SkullKing.PubSub,
          game_id,
          {:update_state, new_game_state}
        )

      error ->
        error
    end
  end
end
