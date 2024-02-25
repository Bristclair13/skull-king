defmodule SkullKingWeb.Live.Home do
  use SkullKingWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gradient-to-r from-red-900 to-neutral-50">
      <h1 class="flex justify-start mt-20 text-9xl text-black">Skull King</h1>
      <img class="flex self-start h-4/6 ml-auto mr-20 mt-6 rounded-full" src="images/home_page.jpeg" />
    </div>
    """
  end
end
