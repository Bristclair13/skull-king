defmodule SkullKing.GamesTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Storage

  describe "score_round/1" do
    test "everyone makes their bid" do
      round = build(:round, number: 4)
      user_1 = build(:user)
      user_2 = build(:user)
      user_3 = build(:user)

      round_user_1 =
        build(:round_user,
          user: user_1,
          user_id: user_1.id,
          round: round,
          round_id: round.id,
          tricks_bid: 3
        )

      round_user_2 =
        build(:round_user,
          user: user_2,
          user_id: user_2.id,
          round: round,
          round_id: round.id,
          tricks_bid: 0
        )

      round_user_3 =
        build(:round_user,
          user: user_3,
          user_id: user_3.id,
          round: round,
          round_id: round.id,
          tricks_bid: 1
        )

      round = %{round | round_users: [round_user_1, round_user_2, round_user_3]}

      trick_1 = build(:trick, round: round, number: 1, winning_user_id: user_1.id)
      trick_2 = build(:trick, round: round, number: 2, winning_user_id: user_1.id)
      trick_3 = build(:trick, round: round, number: 3, winning_user_id: user_3.id)
      trick_4 = build(:trick, round: round, number: 4, winning_user_id: user_1.id)

      Storage.Mock
      |> expect(:get_tricks_for_round, fn ^round ->
        [trick_1, trick_2, trick_3, trick_4]
      end)
      |> expect(:update_round_user_score, fn ^round_user_1,
                                             %{
                                               tricks_won: 3,
                                               bid_points_won: 60,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_1}
      end)
      |> expect(:update_round_user_score, fn ^round_user_2,
                                             %{
                                               tricks_won: 0,
                                               bid_points_won: 40,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_2}
      end)
      |> expect(:update_round_user_score, fn ^round_user_3,
                                             %{
                                               tricks_won: 1,
                                               bid_points_won: 20,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_3}
      end)

      assert :ok = SkullKing.Games.score_round(round)
    end

    test "miss bid when bidding 0 and 3" do
      round = build(:round, number: 4)
      user_1 = build(:user)
      user_2 = build(:user)
      user_3 = build(:user)

      round_user_1 =
        build(:round_user,
          user: user_1,
          user_id: user_1.id,
          round: round,
          round_id: round.id,
          tricks_bid: 3
        )

      round_user_2 =
        build(:round_user,
          user: user_2,
          user_id: user_2.id,
          round: round,
          round_id: round.id,
          tricks_bid: 0
        )

      round_user_3 =
        build(:round_user,
          user: user_3,
          user_id: user_3.id,
          round: round,
          round_id: round.id,
          tricks_bid: 1
        )

      round = %{round | round_users: [round_user_1, round_user_2, round_user_3]}

      trick_1 = build(:trick, round: round, number: 1, winning_user_id: user_1.id)
      trick_2 = build(:trick, round: round, number: 2, winning_user_id: user_2.id)
      trick_3 = build(:trick, round: round, number: 3, winning_user_id: user_3.id)
      trick_4 = build(:trick, round: round, number: 4, winning_user_id: user_1.id)

      Storage.Mock
      |> expect(:get_tricks_for_round, fn ^round ->
        [trick_1, trick_2, trick_3, trick_4]
      end)
      |> expect(:update_round_user_score, fn ^round_user_1,
                                             %{
                                               tricks_won: 2,
                                               bid_points_won: -10,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_1}
      end)
      |> expect(:update_round_user_score, fn ^round_user_2,
                                             %{
                                               tricks_won: 1,
                                               bid_points_won: -40,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_2}
      end)
      |> expect(:update_round_user_score, fn ^round_user_3,
                                             %{
                                               tricks_won: 1,
                                               bid_points_won: 20,
                                               bonus_points_won: 0
                                             } ->
        {:ok, round_user_3}
      end)

      assert :ok = SkullKing.Games.score_round(round)
    end
  end
end
