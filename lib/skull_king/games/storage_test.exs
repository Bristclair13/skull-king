defmodule SkullKing.Games.StorageTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Storage
  alias SkullKing.Games.Game
  alias SkullKing.Games.GameUser
  alias SkullKing.Games.Round
  alias SkullKing.Games.RoundUser
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

  test "add_user_to_game/2" do
    %{id: user_id} = user = insert(:user)
    %{id: game_id} = game = insert(:game)

    {:ok,
     %GameUser{
       user_order: 0,
       game_id: ^game_id,
       user_id: ^user_id
     }} = Storage.add_user_to_game(user, game)
  end

  test "create_round/1" do
    %{id: game_id} = game = insert(:game)

    {:ok,
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
    %{id: game_id} = game = insert(:game)
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
end
