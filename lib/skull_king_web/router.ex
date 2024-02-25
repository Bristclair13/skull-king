defmodule SkullKingWeb.Router do
  use SkullKingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SkullKingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug SkullKingWeb.Plugs.EnsureAuthenticated
  end

  scope "/auth", SkullKingWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/", SkullKingWeb do
    pipe_through :browser

    get "/login", PageController, :login
  end

  scope "/", SkullKingWeb.Live do
    pipe_through [:browser, :authenticated]

    live "/", Home
    live "/games/join", Home
    live "/games/create", CreateGame
    live "/games/:id", Game
  end

  # Other scopes may use custom stacks.
  # scope "/api", SkullKingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:skull_king, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SkullKingWeb.Telemetry
    end
  end
end
