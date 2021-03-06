defmodule Hub.Client.Base do
  @moduledoc false

  @callback call(Map.t()) :: Map.t()
  @callback handle_call(Map.t(), any, any) :: Tuple.t()
  @callback call_hub(Map.t()) :: Map.t()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Hub.Client.Base
      use GenServer
      require Logger

      def start_link(args \\ :ok, opts \\ []) do
        GenServer.start_link(__MODULE__, args, Keyword.merge(opts, name: __MODULE__))
      end

      def init(args) do
        {:ok, args}
      end

      defp decode(body) do
        Poison.decode!(body)
      end

      def terminate(_msg, state) do
        Logger.info("Hub client #{__MODULE__} terminate")
        {:noreply, state}
      end

      defoverridable init: 1, decode: 1
    end
  end
end
