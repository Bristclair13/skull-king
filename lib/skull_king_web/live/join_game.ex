defmodule SkullKingWeb.Live.JoinGame do
  use SkullKingWeb, :live_view

  alias SkullKing.Games

  def mount(_params, session, socket) do
    user = session["current_user"]
    form = to_form(%{"join_code" => ""})
    {:ok, assign(socket, user: user, form: form)}
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-submit="join">
      <.input field={@form[:join_code]} label="Join Code" />
      <:actions>
        <.button>Join</.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("join", %{"join_code" => join_code}, socket) do
    case Games.join_game(socket.assigns.user, join_code) do
      {:ok, game} ->
        {:noreply, push_navigate(socket, to: ~p"/games/#{game.id}")}

        Phoenix.PubSub.broadcast(SkullKing.PubSub, "update_game_id", {:update_game_id, game.id})
        {:noreply, assign(socket, :game_id, game.id)}

      {:error, :game_not_found} ->
        form = to_form(%{"join_code" => join_code}, errors: [join_code: {"Game not found", []}])
        {:noreply, assign(socket, form: form)}

      _error ->
        form =
          to_form(%{"join_code" => join_code},
            errors: [join_code: {"Something went wrong, try again never", []}]
          )

        {:noreply, assign(socket, form: form)}
    end
  end
end
