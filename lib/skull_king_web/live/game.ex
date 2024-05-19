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

    %State.Game{} = state = State.get_game(game_id)

    {:ok, assign(socket, game: game, user: user, tricks_bid: nil, state: state)}
  end

  def render(assigns) do
    my_bid =
      case assigns.state.round do
        %{round_users: round_users} when is_list(round_users) ->
          Enum.find_value(round_users, fn round_user ->
            round_user.user_id == assigns.user.id && round_user.tricks_bid
          end)

        _other ->
          nil
      end

    my_cards = Map.get(assigns.state.cards, assigns.user.id, [])

    assigns = assign(assigns, my_cards: my_cards, my_bid: my_bid)

    ~H"""
    <div
      :if={@state.current_user_id == @user.id}
      class="absolute top-0 left-0 right-0 h-14 flex items-center justify-center"
    >
      <div class="inline-flex items-center rounded-md bg-indigo-50 px-2 py-1 text-xs font-medium text-indigo-700 ring-1 ring-inset ring-indigo-700/10">
        It's your turn
      </div>
    </div>
    <div :if={is_nil(@state.round)} class="h-full">
      <div class="temple-background w-full h-full"></div>
    </div>
    <div>
      <div :if={is_nil(@state.round)}>
        <div class="absolute inset-x-1/3 inset-y-1/3 border-2 w-1/3 p-16 text-6xl">
          Join Code: <%= @game.join_code %>
        </div>
        <div class="absolute top-16 left-8 text-6xl underline underline-offset-4 w-1/3">
          Players joined
          <div :for={user <- @game.users} class="text-4xl mt-4">
            <%= user.name %>
          </div>
        </div>
        <.button class="absolute bottom-2 right-2 h-20 w-40 text-xl" phx-click="start_round">
          Start Game
        </.button>
      </div>
      <div :if={@state.current_user_id == @user.id and @state.round_complete}>
        <.button class="absolute bottom-2 right-2 h-20 w-40 text-xl" phx-click="start_round">
          Start Next Round
        </.button>
      </div>
      <div :for={card <- @state.cards_played}>
        <img src={card.image} class="h-48 w-40" />
      </div>
      <div
        :if={not @state.bidding_complete and not is_nil(@state.round)}
        class="w-96 mx-auto bg-white p-4 mt-8 rounded"
      >
        <.bidding_form game={@game} round={@state.round} user={@user} tricks_bid={@tricks_bid} />
      </div>
      <div
        :if={@state.current_user_id != @user.id}
        class="flex justify-center absolute bottom-0 left-0 right-0"
      >
        <div :for={card <- @my_cards}>
          <img src={card.image} class="h-48 w-40" />
        </div>
      </div>
      <div class="text-3xl text-white absolute right-6 top-16">
        <div :if={@state.bidding_complete}>Your tricks bid: <%= @my_bid %></div>
      </div>
      <div :if={@state.current_user_id == @user.id}>
        <div class="flex justify-center absolute bottom-0 left-0 right-0 gap-x-2 mb-2">
          <div :for={card <- Deck.mark_cards_as_playable(@my_cards, @state.cards_played)}>
            <.button
              :if={card.playable and card.special != :tigress}
              phx-click="select_card"
              phx-value-id={card.id}
              data-confirm="Select Card"
            >
              <img src={card.image} class="h-48 w-40" />
            </.button>
            <div :if={card.playable and card.special == :tigress}>
              <img src={card.image} class="h-48 w-40" />
              <.button>
                Play as pirate
              </.button>
              <.button>
                Play as surrender
              </.button>
            </div>
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

  def handle_info({:update_state, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(:submitted_bid, socket) do
    {:noreply, socket}
  end

  def handle_event("start_round", _params, socket) do
    Games.start_round(socket.assigns.game)

    {:noreply, socket}
  end

  def handle_event("bid", %{"round_user" => %{"tricks_bid" => tricks_bid}}, socket) do
    Games.save_bid(
      socket.assigns.game,
      socket.assigns.state.round,
      socket.assigns.user,
      tricks_bid
    )

    {:noreply, socket}
  end

  def handle_event("update_bid", %{"round_user" => %{"tricks_bid" => tricks_bid}}, socket) do
    {:noreply, assign(socket, tricks_bid: tricks_bid)}
  end

  def handle_event("select_card", %{"id" => card_id}, socket) do
    state = socket.assigns.state
    my_cards = state.cards[socket.assigns.user.id]
    card_played = Enum.find(my_cards, &(&1.id == card_id))
    cards_played = [card_played | state.cards_played]
    my_remaining_cards = Enum.reject(my_cards, &(&1.id == card_id))
    remaining_cards = Map.put(state.cards, socket.assigns.user.id, my_remaining_cards)

    state =
      if length(cards_played) == length(state.round.round_users) do
        # trick is over
        bonus_points = Deck.bonus_points_for_trick(cards_played)
        winning_card = Deck.winning_card(cards_played)

        {:ok, _trick} =
          Games.save_trick(
            socket.assigns.game,
            winning_card.user_id,
            bonus_points
          )

        round_complete =
          Enum.all?(remaining_cards, fn {_user_id, cards} -> Enum.empty?(cards) end)

        if round_complete do
          Games.score_round(socket.assigns.game, state.round)
        end

        %{
          state
          | cards_played: [],
            cards: remaining_cards,
            current_user_id: winning_card.user_id,
            last_trick_cards_played: cards_played,
            trick_number: state.trick_number + 1,
            round_complete: round_complete
        }
      else
        %{
          state
          | cards_played: cards_played,
            cards: remaining_cards,
            current_user_id: Games.next_user(socket.assigns.game, state.current_user_id)
        }
      end

    State.update_game(socket.assigns.game.id, state)

    {:noreply, socket}
  end

  defp bidding_form(assigns) do
    form =
      RoundUser.changeset(%RoundUser{}, %{
        game_id: assigns.game.id,
        user_id: assigns.user.id,
        tricks_bid: assigns.tricks_bid,
        round: assigns.round
      })
      |> Map.put(:action, :insert)
      |> to_form()

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
