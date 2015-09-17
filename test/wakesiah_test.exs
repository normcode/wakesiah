defmodule WakesiahTest do
  require Logger
  use ExUnit.Case, async: true

  setup context do
    {:ok, pid} = Wakesiah.start_link(name: context.test)

    on_exit fn ->
      Wakesiah.stop pid
    end

    {:ok, [pid: pid]}
  end

  test "membership list is empty on start", %{pid: pid} do
    assert Wakesiah.members(pid) == []
  end

  test "connecting to a process", %{pid: pid} do
    assert {:ok, _} = Wakesiah.connect(pid, pid)
    assert Wakesiah.members(pid) == [%Wakesiah.Member{pid: pid, status: :ok}]
  end

  @tag :distributed
  test "connecting to a remote process", %{pid: pid} do
    remote_node = Application.get_env(:wakesiah, :test_remote_name)
    assert {:ok, _} = Wakesiah.connect(pid, remote_node)
    assert Wakesiah.members(pid) |> Enum.all?(&remote_node?/1)
    assert Wakesiah.members({:wakesiah, remote_node}) == [
      %Wakesiah.Member{pid: pid, status: :ok}
    ]
  end

  test "connection timeout", %{pid: pid} do
    stub = spawn_link(fn ->
      :timer.sleep(10000)
    end)
    Logger.debug("Testing connection timeout: #{inspect stub}")
    assert {:error, :timeout} = Wakesiah.connect(pid, stub)
    assert Wakesiah.members(pid) == []
  end

  def remote_node?(n), do: n != node()

end
