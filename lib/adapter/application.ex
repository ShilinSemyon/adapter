defmodule Adapter.Application do
  use Application

  def start(_type, _args) do
    Envy.auto_load
    import Supervisor.Spec
    if System.get_env("MIX_ENV") == "dev", do: :observer.start

    children = [
      supervisor(Adapter.Repo, []),
      {DynamicSupervisor, name: Adapter.MessengersSupervisor, strategy: :one_for_one},
      {Adapter.Registry, name: Adapter.Registry},
      supervisor(AdapterWeb.Endpoint, []),
#      supervisor(Adapter.GeneralSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Adapter.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AdapterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end