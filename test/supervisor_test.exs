defmodule SupervisorTest do
  use ExUnit.Case, async: true

  @test_worker_name __MODULE__

  setup do
    {:ok, pid} = Wakesiah.Supervisor.start_link(worker_name: @test_worker_name)

    on_exit fn ->
      Process.exit(pid, :normal)
    end

    {:ok, [pid: pid]}
  end

  test "supervisor starts worker", %{pid: sup_pid} do
    worker_pid = Process.whereis(@test_worker_name)
    children = Supervisor.which_children(sup_pid)

    assert children == [{Wakesiah, worker_pid, :worker, [Wakesiah]}]
    assert ({:registered_name, @test_worker_name} ==
      Process.info(worker_pid, :registered_name))
  end

end
