defmodule SupervisorTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, pid} = Wakesiah.Supervisor.start_link(worker_name: context.test)

    on_exit fn ->
      Process.exit(pid, :normal)
    end

    {:ok, [pid: pid]}
  end

  test "supervisor starts worker", context = %{pid: sup_pid} do
    worker_pid = Process.whereis(context.test)
    children = Supervisor.which_children(sup_pid)

    assert children == [{Wakesiah, worker_pid, :worker, [Wakesiah]}]
    assert {:registered_name, context.test} ==
      Process.info(worker_pid, :registered_name)
  end

end
