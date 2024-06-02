defmodule SkullKing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkullKing.Repo,
      {Phoenix.PubSub, name: SkullKing.PubSub},
      SkullKing.Games.State,
      # Start a worker by calling: SkullKing.Worker.start_link(arg)
      # {SkullKing.Worker, arg},
      # Start to serve requests, typically the last entry
      SkullKingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SkullKing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkullKingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
