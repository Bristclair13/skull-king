defmodule SkullKingWeb.Live.Game do
  use SkullKingWeb, :live_view

  alias SkullKing.Games
  alias SkullKing.Games.State
  alias SkullKing.Games.Deck
  alias SkullKing.Games.RoundUser

  def mount(%{"id" => game_id}, session, socket) do
    user = session["current_user"]
    game = Games.get(game_id)
    Phoenix.PubSub.subscribe(SkullKing.PubSub, game.id)

    socket =
      case State.get_game(game_id) do
        %{cards: cards} = info ->
          my_cards = cards[user.id]
          assigns = Map.put(info, :my_cards, my_cards)

          assign(socket, assigns)

        nil ->
          assign(socket,
            cards: [],
            my_cards: [],
            cards_played: [],
            current_user_id: nil,
            round: nil,
            bidding_complete: false
          )
      end

    {:ok, assign(socket, game: game, user: user, tricks_bid: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen bg-gray-500">
      <div :if={is_nil(@round)}>
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
      <div :if={not @bidding_complete and not is_nil(@round)}>
        <.bidding_form game={@game} round={@round} user={@user} tricks_bid={@tricks_bid} />
      </div>
      <div :if={@current_user_id != @user.id}>
        <div class="flex flex-row shrink justify-center absolute bottom-0">
          <div :for={card <- @my_cards}>
            <img src={card.image} class="h-48 w-40" />
          </div>
        </div>
      </div>
      <div :if={@current_user_id == @user.id}>
        <p>It's your turn</p>

        <div class="flex flex-row shrink justify-center absolute bottom-0">
          <div :for={card <- Deck.mark_cards_as_playable(@my_cards, @cards_played)}>
            <.button
              :if={card.playable}
              phx-click="select_card"
              phx-value-id={card.id}
              data-confirm="Select Card"
            >
              <img src={card.image} class="h-48 w-40" />
            </.button>
            <img :if={not card.playable} src={card.image} class="opacity-30 h-48 w-40" />
          </div>
        </div>
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
       round: info.round,
       cards: info.cards,
       my_cards: my_cards,
       current_user_id: info.current_user_id,
       bidding_complete: false
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

  def handle_event("bid", %{"round_user" => %{"tricks_bid" => tricks_bid}}, socket) do
    RoundUser.changeset(
      %RoundUser{},
      socket.assigns.round,
      %{
        game_id: socket.assigns.game.id,
        user_id: socket.assigns.user.id,
        tricks_bid: tricks_bid
      }
    )

    Phoenix.PubSub.broadcast(
      Phoenix.PubSub,
      socket.assigns.game.id,
      :submitted_bid
    )

    {:noreply, socket}
  end

  def handle_event("update_bid", %{"round_user" => %{"tricks_bid" => tricks_bid}}, socket) do
    {:noreply, assign(socket, tricks_bid: tricks_bid)}
  end

  def handle_event("select_card", %{"id" => card_id}, socket) do
    my_cards = socket.assigns.my_cards
    card_played = Enum.find(my_cards, &(&1.id == card_id))
    remaining_cards = Enum.reject(my_cards, &(&1.id == card_id))

    info = %{
      cards_played: [card_played | socket.assigns.cards_played],
      cards: Map.put(socket.assigns.cards, socket.assigns.user.id, remaining_cards),
      round: socket.assigns.round,
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

  defp bidding_form(assigns) do
    form =
      RoundUser.changeset(%RoundUser{}, assigns.round, %{
        game_id: assigns.game.id,
        user_id: assigns.user.id,
        tricks_bid: assigns.tricks_bid
      })
      |> Map.put(:action, :insert)
      |> to_form()
      |> dbg()

    assigns = assign(assigns, form: form)

    ~H"""
    <.simple_form for={@form} phx-change="update_bid" phx-submit="bid">
      <.input field={@form[:tricks_bid]} label="How many tricks do you think you'll win?" />
      <:actions>
        <.button>Submit</.button>
      </:actions>
    </.simple_form>
    """
  end
end
