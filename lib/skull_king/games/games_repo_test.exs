defmodule SkullKing.Games.RepoTest do
  use SkullKing.DataCase, async: true

  alias SkullKing.Games.Repo
  alias SkullKing.Games.Game

  test "get/1" do
    game = insert(:game)

    assert %Game{} = Repo.get(game.id)

    assert is_nil(Repo.get("not found"))
  end
end
