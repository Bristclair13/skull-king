defmodule SkullKingWeb.PageController do
  use SkullKingWeb, :controller

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

  def home(conn, _params) do
    render(conn, :home)
  end
end
