defmodule SkullKingWeb.Live.CreateGame do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(_params, _session, socket) do
    {:ok, game} = Games.create()
    {:ok, push_navigate(socket, to: ~p"/games/#{game.id}")}
  end
end
