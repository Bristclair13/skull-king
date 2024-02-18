defmodule SkullKingWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if user = get_session(conn, :current_user) do
      assign(conn, :current_user, user)
    else
      conn
      |> redirect(to: "/login")
      |> halt
    end
  end
end
