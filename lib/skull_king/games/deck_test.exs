defmodule SkullKing.Games.DeckTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Deck

  @black_10 %Deck.Card{color: :black, value: 10}
  @black_14 %Deck.Card{color: :black, value: 14}
  @black_3 %Deck.Card{color: :black, value: 3}
  @black_5 %Deck.Card{color: :black, value: 5}
  @mermaid %Deck.Card{special: :mermaid}
  @pirate %Deck.Card{special: :pirate}
  @purple_11 %Deck.Card{color: :purple, value: 11}
  @purple_14 %Deck.Card{color: :purple, value: 14}
  @skull_king %Deck.Card{special: :skull_king}
  @surrender %Deck.Card{id: 1, value: 0, special: :surrender}
  @surrender_2 %Deck.Card{id: 2, value: 0, special: :surrender}
  @yellow_14 %Deck.Card{color: :yellow, value: 14}
  @yellow_5 %Deck.Card{color: :yellow, value: 5}

  test "deal/2" do
    round = build(:round)
    %{id: user_1_id} = user_1 = build(:user)
    %{id: user_2_id} = user_2 = build(:user)
    %{id: user_3_id} = user_3 = build(:user)

    users = [user_1, user_2, user_3]

    assert %{
             ^user_1_id => [%SkullKing.Games.Deck.Card{user_id: ^user_1_id}],
             ^user_2_id => [%SkullKing.Games.Deck.Card{user_id: ^user_2_id}],
             ^user_3_id => [%SkullKing.Games.Deck.Card{user_id: ^user_3_id}]
           } = Deck.deal(round, users)

    round = build(:round, number: 3)
    %{id: user_1_id} = user_1 = build(:user)
    %{id: user_2_id} = user_2 = build(:user)
    %{id: user_3_id} = user_3 = build(:user)

    users = [user_1, user_2, user_3]

    assert %{
             ^user_1_id => [
               %SkullKing.Games.Deck.Card{user_id: ^user_1_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_1_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_1_id}
             ],
             ^user_2_id => [
               %SkullKing.Games.Deck.Card{user_id: ^user_2_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_2_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_2_id}
             ],
             ^user_3_id => [
               %SkullKing.Games.Deck.Card{user_id: ^user_3_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_3_id},
               %SkullKing.Games.Deck.Card{user_id: ^user_3_id}
             ]
           } = Deck.deal(round, users)
  end

  test "allowed_cards/2" do
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

    cards_played = [@skull_king, @mermaid]
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

    # non special card loses even if played first

    cards_played = [@yellow_14, @skull_king]
    assert @skull_king == Deck.winning_card(cards_played)

    # higher value wins when color is the same

    cards_played = [@yellow_5, @yellow_14]
    assert @yellow_14 == Deck.winning_card(cards_played)
  end

  test "bonus_points_for_trick/1" do
    # 40 bonus points for taking skull king with mermaid

    cards_played = [@mermaid, @skull_king]

    assert 40 == Deck.bonus_points_for_trick(cards_played)

    # 30 bonus points for taking pirate with skull king

    cards_played = [@pirate, @skull_king]

    assert 30 == Deck.bonus_points_for_trick(cards_played)

    # 20 bonus points for taking mermaid with a pirate

    cards_played = [@mermaid, @pirate]

    assert 20 == Deck.bonus_points_for_trick(cards_played)

    # 20 points for capturing black 14

    cards_played = [@skull_king, @black_14]

    assert 20 == Deck.bonus_points_for_trick(cards_played)

    # 10 points for capturing non black 14

    cards_played = [@skull_king, @yellow_14]

    assert 10 == Deck.bonus_points_for_trick(cards_played)

    # points will add together

    cards_played = [@pirate, @purple_14, @yellow_14]

    assert 20 == Deck.bonus_points_for_trick(cards_played)
  end

  test "mark_cards_as_playable/2" do
    my_cards = [@pirate, @yellow_5, @black_10, @surrender, @black_5]
    cards_played = [@black_3]

    assert [
             %SkullKing.Games.Deck.Card{
               playable: true,
               color: nil,
               value: nil,
               special: :pirate
             },
             %SkullKing.Games.Deck.Card{
               playable: false,
               color: :yellow,
               value: 5,
               special: nil
             },
             %SkullKing.Games.Deck.Card{
               playable: true,
               color: :black,
               value: 10,
               special: nil
             },
             %SkullKing.Games.Deck.Card{
               playable: true,
               color: nil,
               value: 0,
               special: :surrender
             },
             %SkullKing.Games.Deck.Card{
               playable: true,
               color: :black,
               value: 5,
               special: nil
             }
           ] = Deck.mark_cards_as_playable(my_cards, cards_played)
  end
end
