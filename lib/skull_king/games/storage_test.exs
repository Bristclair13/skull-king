defmodule SkullKing.Games.StorageTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Storage
  alias SkullKing.Games.Game

  test "get/1" do
    game = insert(:game)

    assert %Game{} = Storage.get(game.id)

    assert is_nil(Storage.get("not found"))
  end

  test "get_by/1" do
    game = insert(:game)
  end
end
