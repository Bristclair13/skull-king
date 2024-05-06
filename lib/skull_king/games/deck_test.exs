defmodule SkullKing.Games.DeckTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Deck

  @pirate %Deck.Card{special: :pirate}
  @yellow_5 %Deck.Card{color: :yellow, value: 5}
  @black_10 %Deck.Card{color: :black, value: 10}
  @black_5 %Deck.Card{color: :black, value: 5}
  @surrender %Deck.Card{id: 1, value: 0, special: :surrender}
  @surrender_2 %Deck.Card{id: 2, value: 0, special: :surrender}
  @black_3 %Deck.Card{color: :black, value: 3}
  @skull_king %Deck.Card{special: :skull_king}
  @mermaid %Deck.Card{special: :mermaid}
  @purple_11 %Deck.Card{color: :purple, value: 11}

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

    # can play anything if surrender first

    my_cards = [@pirate, @black_5, @black_10, @surrender]
    cards_played = [@surrender]
    assert my_cards == Deck.allowed_cards(my_cards, cards_played)
  end

  test "winning_card/1" do
    # higher value of same color wins with 2 cards

    cards_played = [@black_5, @black_3]
    assert @black_5 == Deck.winning_card(cards_played)

    # higher value of same color wins with 3 cards

    cards_played = [@black_5, @black_3, @black_10]
    assert @black_10 == Deck.winning_card(cards_played)

    # if all cards played are surrenders, first card wins

    cards_played = [@surrender, @surrender_2]
    assert @surrender == Deck.winning_card(cards_played)

    # if surrender is played first, it loses to everything with 3 cards

    cards_played = [@surrender, @black_5, @yellow_5]
    assert @black_5 == Deck.winning_card(cards_played)

    # mermaid beats skull king

    cards_played = [@mermaid, @skull_king]
    assert @mermaid == Deck.winning_card(cards_played)

    # mermaid beats value cards

    cards_played = [@mermaid, @yellow_5, @black_10]
    assert @mermaid == Deck.winning_card(cards_played)

    # skull_king beats pirate

    cards_played = [@pirate, @skull_king]
    assert @skull_king == Deck.winning_card(cards_played)

    # skull_king beats value cards

    cards_played = [@skull_king, @yellow_5, @black_10]
    assert @skull_king == Deck.winning_card(cards_played)

    # black beats trump

    cards_played = [@yellow_5, @black_10]
    assert @black_10 == Deck.winning_card(cards_played)

    # higher value non trump loses

    cards_played = [@yellow_5, @purple_11]
    assert @yellow_5 == Deck.winning_card(cards_played)
  end
end
