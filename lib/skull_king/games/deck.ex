defmodule SkullKing.Games.Deck do
  defmodule Card do
    defstruct [:playable, :id, :color, :value, :special, :image, :user_id]
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
        not is_nil(suit_card) and card.color == suit_card.color
      end)

    if not is_nil(suit_card) and not is_nil(suit_card.color) and has_suit_card do
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
      Enum.reduce(users, {[], deck}, fn user, {cards_dealt_acc, cards_remaining_acc} ->
        assigned_cards = Enum.take(cards_remaining_acc, cards_per_user)
        cards_with_user_id = Enum.map(assigned_cards, &Map.put(&1, :user_id, user.id))

        {
          [{user.id, cards_with_user_id} | cards_dealt_acc],
          cards_remaining_acc -- assigned_cards
        }
      end)

    Map.new(cards_dealt)
  end

  defp new_deck() do
    basic_cards =
      for value <- 1..14, color <- [:green, :yellow, :purple, :black] do
        %Card{color: color, value: value, image: "/images/cards/#{color}/#{value}.webp"}
      end

    surrender_cards =
      Enum.map(1..5, fn _n ->
        %Card{value: 0, special: :surrender, image: "/images/cards/surrender.webp"}
      end)

    pirate_cards =
      [
        %Card{special: :pirate, image: "/images/cards/pirate-1.webp"},
        %Card{special: :pirate, image: "/images/cards/pirate-2.webp"},
        %Card{special: :pirate, image: "/images/cards/pirate-3.webp"},
        %Card{special: :pirate, image: "/images/cards/pirate-4.webp"},
        %Card{special: :pirate, image: "/images/cards/pirate-5.webp"}
      ]

    mermaid_cards =
      [
        %Card{special: :mermaid, image: "/images/cards/mermaid-1.webp"},
        %Card{special: :mermaid, image: "/images/cards/mermaid-2.webp"}
      ]

    tigress_card =
      %Card{special: :tigress, image: "/images/cards/tigress.webp"}

    skull_king_card =
      %Card{special: :skull_king, image: "images/cards/skull-king.webp"}

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

  def bonus_points_for_trick(cards_played) do
    winning_card = winning_card(cards_played)

    Enum.map(cards_played, fn card ->
      bonus_points_for_card(card, winning_card)
    end)
    |> Enum.sum()
  end

  defp bonus_points_for_card(card, winning_card) do
    case {card, winning_card} do
      {%Card{color: :black, value: 14}, _winning_card} -> 20
      {%Card{value: 14}, _winning_card} -> 10
      {%Card{special: :mermaid}, %Card{special: :pirate}} -> 20
      {%Card{special: :pirate}, %Card{special: :skull_king}} -> 30
      {%Card{special: :skull_king}, %Card{special: :mermaid}} -> 40
      _no_bonus_points -> 0
    end
  end

  def winning_card(cards_played) do
    Enum.find(cards_played, fn card ->
      Enum.all?(cards_played, fn compare_card ->
        card == compare_card or card_wins?(card, compare_card)
      end)
    end)
  end

  defp card_wins?(%Card{special: :surrender}, %Card{special: :surrender}) do
    true
  end

  defp card_wins?(%Card{special: :surrender}, _compare_card) do
    false
  end

  defp card_wins?(_card, %Card{special: :surrender}) do
    true
  end

  defp card_wins?(%Card{special: :skull_king}, %Card{special: :mermaid}) do
    false
  end

  defp card_wins?(%Card{special: :skull_king}, _compare_card) do
    true
  end

  defp card_wins?(%Card{special: :mermaid}, %Card{special: :pirate}) do
    false
  end

  defp card_wins?(%Card{special: :mermaid}, _compare_card) do
    true
  end

  defp card_wins?(%Card{special: :pirate}, %Card{special: :skull_king}) do
    false
  end

  defp card_wins?(%Card{special: :pirate}, _compare_card) do
    true
  end

  # all special cards have been matched by this point
  # we know it is a color card
  @specials [:mermaid, :pirate, :skull_king, :surrender]
  defp card_wins?(_card, %Card{special: special}) when special in @specials do
    false
  end

  defp card_wins?(%Card{value: value, color: :black}, %Card{value: compare_value, color: :black}) do
    value > compare_value
  end

  defp card_wins?(%Card{color: :black}, _compare_card) do
    true
  end

  defp card_wins?(_card, %Card{color: :black}) do
    false
  end

  defp card_wins?(
         %Card{value: value, color: color},
         %Card{
           value: compare_value,
           color: compare_color
         }
       )
       when color ==
              compare_color do
    value > compare_value
  end

  defp card_wins?(_card, _compare_card) do
    true
  end
end
