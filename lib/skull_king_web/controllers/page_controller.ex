defmodule SkullKingWeb.PageController do
  use SkullKingWeb, :controller

  def home(conn, _params) do
    user = get_session(conn, :current_user)
    render(conn, :home, layout: false, user: user)
  end
end
