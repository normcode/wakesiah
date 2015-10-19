defmodule SupervisorTest do

  use ExUnit.Case, async: true

  setup context do
    {:ok, pid} = Wakesiah.Supervisor.start_link(
      worker_name: context.test,
      failure_detector: String.to_atom("#{context.test}_failure_detector"))

    on_exit fn ->
      Process.exit(pid, :normal)
    end

    {:ok, [pid: pid]}
  end

  test "supervisor starts worker", context = %{pid: sup_pid} do
    worker_pid = Process.whereis(context.test)
    fd_pid = Process.whereis(String.to_atom("#{context.test}_failure_detector"))
    children = Supervisor.which_children(sup_pid)
    assert {Wakesiah, worker_pid, :worker, [Wakesiah]} in children
    assert {Wakesiah.FailureDetector, fd_pid, :worker, [Wakesiah.FailureDetector]} in children
    assert {:registered_name, context.test} == Process.info(worker_pid, :registered_name)
  end

end
