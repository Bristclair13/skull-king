defmodule SkullKing.Games.StorageTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Game
  alias SkullKing.Games.GameUser
  alias SkullKing.Games.Round
  alias SkullKing.Games.RoundUser
  alias SkullKing.Games.Storage
  alias SkullKing.Games.Trick

  test "get/1" do
    game = insert(:game)

    assert %Game{} = Storage.get(game.id)

    assert is_nil(Storage.get("not found"))
  end

  test "get_by/1" do
    game = insert(:game)

    assert {:ok, ^game} = Storage.get_by(join_code: game.join_code)

    assert {:error, :game_not_found} == Storage.get_by(join_code: "not found")
  end

  test "create/0" do
    {:ok, game} = assert {:ok, %Game{}} = Storage.create()

    assert String.length(game.join_code) == 10
  end

  test "load_round_users/1" do
    %{id: game_id} = insert(:game)
    %{id: round_id} = round = insert(:round, number: 4, game_id: game_id)

    %{id: user_1_id} = insert(:user)
    %{id: user_2_id} = insert(:user)
    %{id: user_3_id} = insert(:user)

    %{id: round_user_1_id} =
      insert(:round_user,
        user_id: user_1_id,
        round: round,
        round_id: round_id,
        tricks_bid: 3,
        game_id: game_id
      )

    %{id: round_user_2_id} =
      insert(:round_user,
        user_id: user_2_id,
        round: round,
        round_id: round_id,
        tricks_bid: 0,
        game_id: game_id
      )

    %{id: round_user_3_id} =
      insert(:round_user,
        user_id: user_3_id,
        round: round,
        round_id: round_id,
        tricks_bid: 1,
        game_id: game_id
      )

    assert %{
             round_users: [
               %{id: ^round_user_1_id},
               %{id: ^round_user_2_id},
               %{id: ^round_user_3_id}
             ]
           } =
             Storage.load_round_users(round)
  end

  test "add_user_to_game/2" do
    %{id: user_id} = user = insert(:user)
    %{id: game_id} = game = insert(:game)

    assert {:ok,
            %GameUser{
              user_order: 0,
              game_id: ^game_id,
              user_id: ^user_id
            }} = Storage.add_user_to_game(user, game)
  end

  test "create_round/1" do
    %{id: game_id} = game = insert(:game)

    assert {:ok,
            %Round{
              number: 1,
              game_id: ^game_id
            }} = Storage.create_round(game)
  end

  test "create_round_user/1" do
    %{id: user_id} = insert(:user)
    %{id: game_id} = insert(:game)
    round = insert(:round, number: 4, game_id: game_id)

    params = %{
      game_id: game_id,
      user_id: user_id,
      tricks_bid: 0,
      round: round
    }

    assert {:ok, %RoundUser{}} = Storage.create_round_user(params)
  end

  test "create_trick/1" do
    %{id: game_id} = insert(:game)
    %{id: round_id} = insert(:round, game_id: game_id)
    %{id: user_id} = insert(:user)

    params = %{
      bonus_points: 0,
      number: 1,
      game_id: game_id,
      round_id: round_id,
      winning_user_id: user_id
    }

    assert {:ok, %Trick{}} = Storage.create_trick(params)
  end

  test "update_round_user_score/2" do
    %{id: user_id} = insert(:user)
    %{id: game_id} = insert(:game)
    round = insert(:round, number: 4, game_id: game_id)
    round_user = insert(:round_user, game_id: game_id, user_id: user_id, round: round)

    params = %{
      tricks_won: 2,
      bid_points_won: 40,
      bonus_points_won: 10
    }

    assert {:ok,
            %RoundUser{
              tricks_won: 2,
              bid_points_won: 40,
              bonus_points_won: 10
            }} = Storage.update_round_user_score(round_user, params)
  end

  test "get_tricks_for_round/1" do
    %{id: game_id} = insert(:game)
    %{id: round_id} = round = insert(:round, number: 4, game_id: game_id)
    %{id: user_id} = insert(:user)

    trick_1 =
      insert(:trick, number: 1, game_id: game_id, round_id: round_id, winning_user_id: user_id)

    trick_2 =
      insert(:trick, number: 2, game_id: game_id, round_id: round_id, winning_user_id: user_id)

    trick_3 =
      insert(:trick, number: 3, game_id: game_id, round_id: round_id, winning_user_id: user_id)

    trick_4 =
      insert(:trick, number: 4, game_id: game_id, round_id: round_id, winning_user_id: user_id)

    round = %{round | tricks: [trick_1, trick_2, trick_3, trick_4]}

    assert [^trick_1, ^trick_2, ^trick_3, ^trick_4] =
             Storage.get_tricks_for_round(round)
  end
end
