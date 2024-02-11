defmodule SkullKing.UsersTest do
  use SkullKing.DataCase

  alias SkullKing.Users
  alias SkullKing.Users.Repo

  test "find_or_create/1" do
    user = build(:user)

    # user doesn't exist
    Repo.Mock
    |> expect(:get, fn "google_id" ->
      nil
    end)
    |> expect(:create, fn %{name: _name, google_id: "google_id"} ->
      {:ok, user}
    end)

    assert {:ok, ^user} = Users.find_or_create("google_id")

    # user already exist
    Repo.Mock
    |> expect(:get, fn "google_id" ->
      user
    end)

    assert {:ok, ^user} = Users.find_or_create("google_id")
  end
end
