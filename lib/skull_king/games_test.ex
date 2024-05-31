defmodule SkullKing.GamesTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Storage

  test "score_round/1" do
    # We need to create round_users and pass them into round
    # round user tells you how much they bid

    round = build(:round, number: 3)
    %{id: user_1_id} = user_1 = build(:user)
    %{id: user_2_id} = user_2 = build(:user)
    %{id: user_3_id} = user_3 = build(:user)

    trick_1 = build(:trick, round: round, number: 1, winning_user_id: user_1_id)

    trick_2 = build(:trick, round: round, number: 2, winning_user_id: user_1_id)

    trick_3 = build(:trick, round: round, number: 3, winning_user_id: user_3_id)

    Storage.Mock
    |> expect(:get_tricks_for_round, fn ^round ->
      [trick_1, trick_2, trick_3]
    end)

    # We should expect an update round_user score for each user
    assert :ok = SkullKing.Games.score_round(round)
  end
end
