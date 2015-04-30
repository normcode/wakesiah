defmodule WakesiahTest.StartTests do
  use ExUnit.Case, async: true

  test "start_link with name option" do
    {:ok, pid} = Wakesiah.start_link(name: :test)
    assert Process.whereis(:test) == pid
    assert {:links, [self]} == Process.info(pid, :links)
    Wakesiah.stop pid
  end

  test "start_link without name option" do
    assert {:ok, pid} = Wakesiah.start_link
    assert {:links, [self]} == Process.info(pid, :links)
    Wakesiah.stop pid
  end

  test "start with name option" do
    {:ok, pid} = Wakesiah.start(name: :test)
    assert Process.whereis(:test) == pid
    assert {:links, []} == Process.info(pid, :links)
    Wakesiah.stop pid
  end

  test "start without name option" do
    {:ok, pid} = Wakesiah.start
    assert {:links, []} == Process.info(pid, :links)
    Wakesiah.stop pid
  end
end
