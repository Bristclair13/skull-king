defmodule SkullKing.Users.StorageTest do
  use SkullKing.DataCase

  alias SkullKing.Users.Storage
  alias SkullKing.Users.User

  test "get/1" do
    assert nil == Storage.get("google_id")
    user = insert(:user)
    assert ^user = Storage.get(user.google_id)
  end

  test "create/1" do
    params = %{
      name: "name",
      google_id: "my_id"
    }

    assert {:ok,
            %User{
              name: "name",
              google_id: "my_id"
            }} = Storage.create(params)
  end
end
