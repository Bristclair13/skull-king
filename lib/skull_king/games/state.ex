defmodule SkullKing.Games.State do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call({:get_game, game_id}, _from, state) do
    game_info = Map.get(state, game_id)

    {:reply, game_info, state}
  end

  def handle_cast({:update_game, game_id, info}, state) do
    new_state = Map.put(state, game_id, info)

    {:noreply, new_state}
  end

  def get_game(game_id) do
    GenServer.call(__MODULE__, {:get_game, game_id})
  end

  def update_game(game_id, info) do
    GenServer.cast(__MODULE__, {:update_game, game_id, info})
  end
end
