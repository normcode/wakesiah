defmodule WakesiahTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Wakesiah.start

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
    assert Wakesiah.members(pid) == [node()]
  end

  @tag :distributed
  test "connecting to a remote process", %{pid: pid} do
    remote_node = Application.get_env(:wakesiah, :test_remote_name)
    assert {:ok, _} = Wakesiah.connect(pid, remote_node)
    assert Wakesiah.members(pid) |> Enum.all?(&remote_node?/1)
    assert Wakesiah.members({:wakesiah, remote_node}) == [node()]
  end

  def remote_node?(n), do: n != node()

end
