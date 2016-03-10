# GprocExample

A simple spike to see to play with [gproc](https://github.com/uwiger/gproc).

### Idea

A simple Event GenServer to create events in the database, as well as notify the Progress projection to calculate the new current state.

### Usage

```elixir
iex(1)> {:ok, progress} = GprocExample.Progress.start_link
{:ok, #PID<0.160.0>}
iex(2)> {:ok, event} = GprocExample.Event.start_link
{:ok, #PID<0.162.0>}
iex(3)> GprocExample.Event.complete_activity(event, %{student_id: 1, activity: 1, lesson: 1})
:ok
iex(4)> GprocExample.Progress.fetch_progress(progress)
Complete Acticity: 1
%GprocExample.Progress.PrecinctState{current_activity: 2, current_map: 1,
 current_position: 1}
iex(5)> GprocExample.Event.complete_activity(event, %{student_id: 1, activity: 11, lesson: 1})
Complete Acticity: 11
:ok
iex(6)> GprocExample.Progress.fetch_progress(progress)
%GprocExample.Progress.PrecinctState{current_activity: 1, current_map: 1,
 current_position: 2}
```

### Tools
- [Event](https://github.com/gogogarrett/gproc_example/blob/master/lib%2Fgproc_example%2Fevent.ex) - create events in the database, cast an event via gproc to progress projection/reducer
- [Progress](https://github.com/gogogarrett/gproc_example/blob/master/lib%2Fgproc_example%2Fprogress.ex) - takes events and returns the current state based on the queue of them
  - idea: if this crashes, load from the DB all of the events - and re-run through them all again?
