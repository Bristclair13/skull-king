defmodule SkullKingWeb.AuthControllerTest do
  use SkullKingWeb.ConnCase, async: true

  describe "GET /auth/:provider/callback" do
    test "success", %{conn: conn} do
      nil
    end

    test "failure", %{conn: conn} do
      assert conn
             |> assign(:ueberauth_failure, "failed")
             |> get("/auth/google/callback")
             |> redirected_to() == "/"
    end
  end
end
