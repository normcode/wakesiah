defmodule Wakesiah.Supervisor do
  use Supervisor

  @default_worker_name :wakesiah
  @default_failure_detector_name :wakesiah_failure_detector

  def start_link(opts \\ []) do
    {seeds, opts} = Keyword.pop(opts, :seeds, [])
    {worker_name, opts} = Keyword.pop(opts, :worker_name, @default_worker_name)
    {failure_detector_name, opts} = Keyword.pop(opts, :failure_detector, @default_failure_detector_name)
    Supervisor.start_link(__MODULE__, {seeds, worker_name, failure_detector_name}, opts)
  end

  def init({seeds, worker_name, failure_detector}) do
    children = [
      worker(Wakesiah.FailureDetector,
             [[name: failure_detector,
               seeds: seeds]]),
      worker(Wakesiah,
             [[name: worker_name,
               failure_detector: failure_detector]]),
    ]
    supervise(children, strategy: :one_for_one)
  end

end
