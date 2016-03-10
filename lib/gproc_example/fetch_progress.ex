defmodule GprocExample.FetchProgress do
  def for(pid) do
    GenServer.call(pid, :fetch_progress)
  end
end
