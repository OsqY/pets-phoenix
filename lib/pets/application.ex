defmodule Pets.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PetsWeb.Telemetry,
      Pets.Repo,
      {DNSCluster, query: Application.get_env(:pets, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pets.PubSub, adapter: Phoenix.PubSub.PG2},
      # Start a worker by calling: Pets.Worker.start_link(arg)
      # {Pets.Worker, arg},
      # Start to serve requests, typically the last entry
      PetsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pets.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PetsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
