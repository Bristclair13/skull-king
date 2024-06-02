defmodule SkullKingWeb.Live.CreateGame do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(_params, session, socket) do
    user = session["current_user"]
    {:ok, game} = Games.create(user)
    {:ok, push_navigate(socket, to: ~p"/games/#{game.id}")}
  end
end
