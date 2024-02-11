defmodule SkullKingWeb.PageController do
  use SkullKingWeb, :controller

  def login(conn, _params) do
    user = get_session(conn, :current_user)
    render(conn, :login, layout: false, user: user)
  end
end
