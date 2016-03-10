defmodule GprocExample.Progress do
  use GenServer

  defmodule Lesson do
    def activity_count(lesson_id, locale) do
      2
    end
  end

  defmodule Student do
    defstruct id: nil, name: "Sample"

    def new do
      # {_,_,id} = :erlang.now
      id = 1

      %Student{
        id: id,
        name: "Hey"
      }
    end
  end

  defmodule PrecinctState do
    defstruct current_map: nil, current_position: nil, current_activity: nil

    def new do
      %PrecinctState{
        current_map: 1,
        current_position: 1,
        current_activity: 1,
      }
    end
  end

  alias GprocExample.Progress.{Student, PrecinctState, Lesson}

  # client api
  def fetch_progress(pid) do
    GenServer.call(pid, :fetch_progress)
  end

  # genserver api
  def start_link do
    GenServer.start_link(__MODULE__, Student.new, [])
  end

  @doc """
    Setup the inital state for monitoring a students progress
    Register globaly with gproc under {:progress, student_id}

    This will setup the `progres` key in the state with a default PrecinctState
    which is a struct that maps `current_map`, `current_position`, and `current_activity`
  """
  def init(%Student{id: id} = student) do
    :gproc.reg({:p, :l, {:progress, id}})

    # imagine this is a list of 3 types of progress, one pre precinct
    {:ok, PrecinctState.new}
  end

  def handle_call(:fetch_progress, _from, progress) do
    {:reply, progress, progress}
  end

  def handle_cast({:complete_activity, lesson, activity}, progress) do
    IO.puts "Complete Acticity: #{inspect activity}"

    new_progress = cond do
      first_time_completing_lesson?(progress, lesson) &&
        completed_last_activity_of_lesson?(progress, lesson) ->

        %{progress | current_position: progress.current_position + 1, current_activity: 1}
      true ->
        %{progress | current_activity: progress.current_activity + 1 }
    end

    {:noreply, new_progress}
  end

  # could easily do something similar for these other types of events
  def handle_cast({:complete_map_quiz, map_number, correct_count, total_count}, progress) do
    {:norereply, progress}
  end
  def handle_cast({:complete_placement_test, lesson}, progress) do
    {:norereply, progress}
  end

  # business logic that gets applied in the projection/reducer
  defp first_time_completing_lesson?(progress, lesson_id) do
    progress.current_position == lesson_id
  end

  defp completed_last_activity_of_lesson?(progress, lesson_id) do
    progress.current_activity >= Lesson.activity_count(lesson_id, "au")
  end
end
