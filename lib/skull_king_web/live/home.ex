defmodule SkullKingWeb.Live.Home do
  use SkullKingWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gradient-to-r from-red-900 to-neutral-50">
      <img class="flex self-start h-4/6 self-center rounded-full" src="images/home_page.jpeg" />
    </div>
    """
  end
end
