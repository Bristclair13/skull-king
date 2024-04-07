defmodule SkullKing.Games.Deck do
  defmodule Card do
    defstruct [:playable, :id, :color, :value, :special, :image]
  end

  def allowed_cards(my_cards, []) do
    my_cards
  end

  def allowed_cards(my_cards, cards_played) do
    characters = [:mermaid, :pirate, :skull_king, :tigress]

    suit_card =
      Enum.find(cards_played, fn card ->
        not is_nil(card.color) or card.special in characters
      end)

    has_suit_card =
      Enum.any?(my_cards, fn card ->
        card.color == suit_card.color
      end)

    if not is_nil(suit_card.color) and has_suit_card do
      Enum.filter(my_cards, fn card ->
        card.color == suit_card.color or is_nil(card.color)
      end)
    else
      my_cards
    end
  end

  def deal(round, users) do
    deck = new_deck()
    cards_per_user = round.number

    {cards_dealt, _cards_remaining} =
      Enum.reduce(users, {[], deck}, fn user, {cards_dealt, cards_remaining} ->
        cards = Enum.take(cards_remaining, cards_per_user)

        {
          [{user.id, cards} | cards_dealt],
          cards_remaining -- cards
        }
      end)

    Map.new(cards_dealt)
  end

  defp new_deck() do
    basic_cards =
      for value <- 1..14, color <- [:green, :yellow, :purple, :black] do
        %Card{color: color, value: value, image: "/images/cards/#{color}-#{value}.jpg"}
      end

    surrender_cards =
      Enum.map(1..5, fn _n ->
        %Card{value: 0, special: :surrender, image: "/images/cards/surrender.jpg"}
      end)

    pirate_cards =
      [
        %Card{special: :pirate, image: "/images/cards/pirate-1.jpg"},
        %Card{special: :pirate, image: "/images/cards/pirate-2.jpg"},
        %Card{special: :pirate, image: "/images/cards/pirate-3.jpg"},
        %Card{special: :pirate, image: "/images/cards/pirate-4.jpg"},
        %Card{special: :pirate, image: "/images/cards/pirate-5.jpg"}
      ]

    mermaid_cards =
      [
        %Card{special: :mermaid, image: "/images/cards/mermaid-1.jpg"},
        %Card{special: :mermaid, image: "/images/cards/mermaid-2.jpg"}
      ]

    tigress_card =
      %Card{special: :tigress, image: "/images/cards/tigress.jpg"}

    skull_king_card =
      %Card{special: :skull_king, image: "images/cards/skull-king.jpg"}

    deck =
      [
        tigress_card,
        skull_king_card
        | basic_cards ++
            surrender_cards ++ pirate_cards ++ mermaid_cards
      ]

    deck
    |> Enum.shuffle()
    |> Enum.map(&Map.put(&1, :id, Ecto.UUID.generate()))
  end

  def mark_cards_as_playable(my_cards, cards_played) do
    allowed_cards = allowed_cards(my_cards, cards_played)

    Enum.map(my_cards, fn card ->
      playable = card in allowed_cards
      Map.put(card, :playable, playable)
    end)
  end
end
