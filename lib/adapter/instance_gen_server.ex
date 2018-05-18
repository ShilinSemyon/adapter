defmodule Adapter.InstanceGenServer do
  @moduledoc false

  use Export.Ruby
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, tl(args), [{:name, hd(args)}])
  end

  def init(args) do
    [instance_name, token] = args
    instance = Adapter.Instance.new(instance_name)
    instance_name |> run([instance, token])
    {:ok, instance}
  end

  def run(instance_name, args) do
    case instance_name do
      :adapter   -> spawn_link Adapter.InstanceGenServer, :adapter, [args]
      :listening -> spawn_link Adapter.InstanceGenServer, :listening, [args]
    end
  end

  def adapter([pid, token]) do
    pid |> Ruby.call("main.rb", "run_bot", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  def listening([pid, token]) do
    pid |> Ruby.call("main.rb", "register_handler", [pid, token, nearest_parent_for(pid)])

    {:ok, pid}
  end

  def handle_cast({:post_message, message}, state) do
    IO.inspect "++++++++++++++++++++++++++++++++++"
    IO.inspect message
    IO.inspect state
    :ruby.cast(state, message) |> IO.inspect
    IO.inspect "++++++++++++++++++++++++++++++++++"
    {:noreply, state}
  end

  def handle_cast({:message, message}, state) do
    IO.inspect "++++++++++++++++++++++++++++++++++"
    IO.inspect message
    IO.inspect state
    :ruby.cast(state, message) |> IO.inspect
    IO.inspect "++++++++++++++++++++++++++++++++++"
    {:noreply, state}
  end

  def handle_info({:receive_message, msg}, state) do
    IO.inspect "=================================="
    IO.inspect msg
    IO.inspect state
    body = call_hub(msg)
    body |> find_current_listener_pid(state) |> :ruby.cast(body)
    IO.inspect "=================================="
    {:noreply, state}
  end

  def terminate(_msg, state) do
    {:noreply, state}
  end

  defp nearest_parent_for(pid, index \\ 0) do
    {:ok, dictionary} = Keyword.fetch(Process.info(pid), :dictionary)
    {:ok, ancestors} = Keyword.fetch(dictionary, :"$ancestors")
    case index do
      0 -> List.first(ancestors) |> Process.whereis()
      _ -> Enum.at(ancestors, index)
    end
  end

  defp call_hub(message) do
    HTTPoison.start
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post System.get_env("DCH_POST"), message, [{"Content-Type", "application/json"}] |> IO.inspect
    body
  end

  defp find_current_listener_pid(body, state) do
    find_pid = &(if String.starts_with?("#{elem(&1, 0)}", "listener"), do: elem(&1, 0))
    nearest_parent_for(state, 1)
    |> Supervisor.which_children()
    |> Enum.find_value(find_pid)
  end
end
