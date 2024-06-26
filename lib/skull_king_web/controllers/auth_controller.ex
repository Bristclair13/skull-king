defmodule SkullKingWeb.AuthController do
  use SkullKingWeb, :controller

  alias SkullKing.Users

  plug Ueberauth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Users.find_or_create(auth.uid) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/login")
    end
  end

  def login_as(conn, %{"id" => id}) do
    {:ok, user} = Users.find_or_create(id)

    conn
    |> put_session(:current_user, user)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end
end
