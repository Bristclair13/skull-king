defmodule SkullKingWeb.Live.Home do
  use SkullKingWeb, :live_view

  def mount(_params, session, socket) do
    user = session["current_user"]
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="skull-pic">
      <h1 class="absolute mt-10 ml-15 text-center text-9xl text-black">SKULL KING</h1>
    </div>
    <div class="flex flex-col absolute right-0 top-20 w-1/2 h-screen">
      <div class="flex shrink border-4 h-32 mr-3 justify-center p-6 text-5xl text-white">
        WELCOME PIRATE <%= @user.name %>
      </div>
      <div class="border-4 h-60 mt-10 mr-3"></div>
      <div class="border-4 h-60 mt-10 mr-3"></div>
    </div>
    """
  end
end
