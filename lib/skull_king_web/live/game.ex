defmodule SkullKingWeb.Live.Game do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(%{"id" => game_id}, _session, socket) do
    Phoenix.PubSub.subscribe(SkullKing.PubSub, "id")

    game = Games.get(game_id)
    {:ok, assign(socket, game: game)}
  end

  def render(assigns) do
    ~H"""
    <div><%= @game.join_code %></div>
    """
  end

  def handle_info(event, socket) do
    {:noreply, assign(socket, game_id: [event["id"] | socket.assigns.id])}
  end
end
