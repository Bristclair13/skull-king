defmodule SkullKing.UsersRepoTest do
  use SkullKing.DataCase

  alias SkullKing.Users.Repo

  test "get/1" do
    assert nil == Repo.get("google_id")
    user = insert(:user)
    assert ^user = Repo.get(user.google_id)
  end
end
