defmodule SkullKingWeb.Live.Game do
  use SkullKingWeb, :live_view

  alias SkullKing.Games
  alias SkullKing.Games.State

  def mount(%{"id" => game_id}, session, socket) do
    user = session["current_user"]
    game = Games.get(game_id)
    Phoenix.PubSub.subscribe(SkullKing.PubSub, game.id)

    socket =
      case State.get_game(game_id) do
        %{cards: cards, round_number: round_number, current_user_id: current_user_id} ->
          my_cards = cards[user.id]

          assign(socket,
            round_number: round_number,
            cards: my_cards,
            current_user_id: current_user_id
          )

        nil ->
          assign(socket,
            cards: [],
            current_user_id: nil,
            round_number: nil
          )
      end

    {:ok, assign(socket, game: game, user: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen bg-gray-500">
      <div :if={is_nil(@round_number)}>
        <div class="border-2 w-1/2 absolute right-0 p-16 text-6xl">
          Join Code: <%= @game.join_code %>
        </div>
        <div :for={user <- @game.users} class="border-2 w-1/3"><%= user.name %></div>
        <.button class="absolute bottom-0 right-0 h-20 w-40 text-xl" phx-click="start_game">
          Start Game
        </.button>
      </div>
      <div :if={@current_user_id == @user.id}>It's your turn</div>
      <div class="flex flex-row shrink justify-center absolute bottom-0">
        <img :for={card <- @cards} src={card.image} class="h-48 w-40" />
      </div>
    </div>
    """
  end

  def handle_info(:user_joined, socket) do
    game = Games.get(socket.assigns.game.id)
    {:noreply, assign(socket, game: game)}
  end

  def handle_info({:round_started, info}, socket) do
    my_cards = info.cards[socket.assigns.user.id]

    {:noreply,
     assign(socket,
       round_number: info.round_number,
       cards: my_cards,
       current_user_id: info.current_user_id
     )}
  end

  def handle_event("start_game", _params, socket) do
    Games.start_round(socket.assigns.game)

    {:noreply, socket}
  end
end
