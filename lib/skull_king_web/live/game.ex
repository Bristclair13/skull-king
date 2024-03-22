defmodule SkullKingWeb.Live.Game do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(%{"id" => game_id}, session, socket) do
    user = session["current_user"]
    game = Games.get(game_id)
    Phoenix.PubSub.subscribe(SkullKing.PubSub, game.id)
    {:ok, assign(socket, game: game, user: user, cards: [])}
  end

  def render(assigns) do
    ~H"""
    <div><%= @game.join_code %></div>
    <div :for={user <- @game.users}><%= user.name %></div>
    <.button phx-click="start_game">Start Game</.button>
    <div class="flex flex-row shrink justify-center absolute bottom-0">
      <img :for={card <- @cards} src={card.image} class="h-48 w-40" />
    </div>
    """
  end

  def handle_info(:user_joined, socket) do
    game = Games.get(socket.assigns.game.id)
    {:noreply, assign(socket, game: game)}
  end

  def handle_info({:round_started, info}, socket) do
    my_cards = info.cards[socket.assigns.user.id]
    {:noreply, assign(socket, round_number: info.number, cards: my_cards)}
  end

  def handle_event("start_game", _params, socket) do
    Games.start_round(socket.assigns.game)

    {:noreply, socket}
  end
end
