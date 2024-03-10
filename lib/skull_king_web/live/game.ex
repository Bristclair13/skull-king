defmodule SkullKingWeb.Live.Game do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(%{"id" => game_id}, _session, socket) do
    game = Games.get(game_id)
    Phoenix.PubSub.subscribe(SkullKing.PubSub, game.id)
    {:ok, assign(socket, game: game)}
  end

  def render(assigns) do
    ~H"""
    <div><%= @game.join_code %></div>
    <div :for={user <- @game.users}><%= user.name %></div>
    """
  end

  def handle_info(:user_joined, socket) do
    game = Games.get(socket.assigns.game.id)
    {:noreply, assign(socket, game: game)}
  end
end
