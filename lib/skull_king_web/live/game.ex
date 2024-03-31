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
        %{
          cards: cards,
          cards_played: cards_played,
          round_number: round_number,
          current_user_id: current_user_id
        } ->
          my_cards = cards[user.id]

          assign(socket,
            round_number: round_number,
            cards: cards,
            my_cards: my_cards,
            current_user_id: current_user_id,
            cards_played: cards_played
          )

        nil ->
          assign(socket,
            cards: [],
            my_cards: [],
            cards_played: [],
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
      <div :for={card <- @cards_played}>
        <img src={card.image} class="h-48 w-40" />
      </div>
      <div :if={@current_user_id == @user.id}>It's your turn</div>
      <div class="flex flex-row shrink justify-center absolute bottom-0">
        <.button
          :for={card <- @my_cards}
          phx-click="select_card"
          phx-value-id={card.id}
          data-confirm="Select Card"
        >
          <img src={card.image} class="h-48 w-40" />
        </.button>
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
       cards: info.cards,
       my_cards: my_cards,
       current_user_id: info.current_user_id
     )}
  end

  def handle_info({:card_played, info}, socket) do
    {:noreply,
     assign(socket, cards_played: info.cards_played, current_user_id: info.current_user_id)}
  end

  def handle_event("start_game", _params, socket) do
    Games.start_round(socket.assigns.game)

    {:noreply, socket}
  end

  def handle_event("select_card", %{"id" => card_id}, socket) do
    my_cards = socket.assigns.my_cards
    card_played = Enum.find(my_cards, &(&1.id == card_id))
    remaining_cards = Enum.reject(my_cards, &(&1.id == card_id))

    info = %{
      cards_played: [card_played | socket.assigns.cards_played],
      cards: Map.put(socket.assigns.cards, socket.assigns.user.id, remaining_cards),
      round_number: socket.assigns.round_number,
      current_user_id: Games.next_user(socket.assigns.game, socket.assigns.current_user_id)
    }

    State.update_game(socket.assigns.game.id, info)

    Phoenix.PubSub.broadcast(
      SkullKing.PubSub,
      socket.assigns.game.id,
      {:card_played, info}
    )

    {:noreply,
     assign(socket,
       my_cards: remaining_cards
     )}
  end
end
