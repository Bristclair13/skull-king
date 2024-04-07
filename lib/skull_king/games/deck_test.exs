defmodule SkullKing.Games.DeckTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Deck

  @pirate %Deck.Card{special: :pirate}
  @yellow_5 %Deck.Card{color: :yellow, value: 5}
  @black_10 %Deck.Card{color: :black, value: 10}
  @black_5 %Deck.Card{color: :black, value: 5}
  @surrender %Deck.Card{value: 0, special: :surrender}
  @black_3 %Deck.Card{color: :black, value: 3}

  test "allowed_cards/2" do
    # my_cards = []
    # cards_played = []
    # assert [] == Deck.allowed_cards(my_cards, cards_played)

    # returns all cards if cards played is empty

    my_cards = [@pirate, @yellow_5, @black_10, @surrender, @black_5]
    cards_played = []
    assert my_cards == Deck.allowed_cards(my_cards, cards_played)

    # returns cards only with same color as card played
    my_cards = [@pirate, @yellow_5, @black_10, @surrender, @black_5]
    cards_played = [@black_3]

    assert [@pirate, @black_10, @surrender, @black_5] ==
             Deck.allowed_cards(my_cards, cards_played)

    # second card assigns trump if a non color card was played first

    my_cards = [@pirate, @yellow_5, @black_10, @surrender]
    cards_played = [@surrender, @black_5]
    assert [@pirate, @black_10, @surrender] == Deck.allowed_cards(my_cards, cards_played)

    # no suit enforced if charcter played
    my_cards = [@pirate, @yellow_5, @black_10, @surrender, @black_5]
    cards_played = [@pirate, @black_3]

    assert my_cards ==
             Deck.allowed_cards(my_cards, cards_played)

    # no suit enforced if charcter played if character played after surrender
    my_cards = [@pirate, @yellow_5, @black_10, @surrender, @black_5]
    cards_played = [@surrender, @pirate, @black_3]

    assert my_cards ==
             Deck.allowed_cards(my_cards, cards_played)

    # if player does not have trump they can play any color

    my_cards = [@pirate, @black_5, @black_10, @surrender]
    cards_played = [@yellow_5]
    assert my_cards == Deck.allowed_cards(my_cards, cards_played)
  end
end
