defmodule AccTournament.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AccTournamentWeb.Telemetry,
      AccTournament.Repo,
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies), [name: AccTournament.ClusterSupervisor]]},
      {Oban, Application.fetch_env!(:acc_tournament, Oban)},
      {Phoenix.PubSub, name: AccTournament.PubSub},
      {NodeJS.Supervisor, [path: LiveVue.SSR.NodeJS.server_path(), pool_size: 4]},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AccTournament.Finch},
      # Start a worker by calling: AccTournament.Worker.start_link(arg)
      # {AccTournament.Worker, arg},
      # Start to serve requests, typically the last entry
      AccTournamentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AccTournament.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AccTournamentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
