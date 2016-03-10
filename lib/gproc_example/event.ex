defmodule GprocExample.Event do
  require Logger
  
  alias __MODULE__

  defstruct student_id: nil, activity: nil

  def changeset(_, event) do
    event
  end

  defmodule Repo do
    def insert(event) do
      {:ok, event}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:complete_activity, %{student_id: s_id, activity: activity, lesson: lesson} = event}, state) do
    event = Event.changeset(%Event{}, event)

    case Repo.insert(event) do
      {:ok, event} ->
        notify_progress_projection(s_id, lesson, activity)
      _ ->
        Logger.error("could not create event", event)
    end

    {:noreply, state}
  end

  defp notify_progress_projection(student_id, lesson, activity) do
    GenServer.cast(
      {:via, :gproc, {:p, :l, {:progress, student_id}}}, # identifier in the registery
      {:complete_activity, lesson, activity} # info relevant to the new progress state
    )
  end
end
