defmodule SkullKing.Users.StorageTest do
  use SkullKing.DataCase

  alias SkullKing.Users.Storage

  test "get/1" do
    assert nil == Storage.get("google_id")
    user = insert(:user)
    assert ^user = Storage.get(user.google_id)
  end
end
