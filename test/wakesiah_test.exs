defmodule WakesiahTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Wakesiah.start_link name: __MODULE__
    {:ok, [pid: pid]}
  end

  test "start_link with name option" do
    {:ok, pid} = Wakesiah.start_link(name: :test)
    assert Process.whereis(:test) == pid
    assert {:links, [self]} == Process.info(pid, :links)
  end

  test "start_link without name option" do
    assert {:ok, pid} = Wakesiah.start_link
    assert {:links, [self]} == Process.info(pid, :links)
  end
  
  test "membership list is empty on start", %{pid: pid} do
    assert Wakesiah.members(pid) == []
  end

  
end
