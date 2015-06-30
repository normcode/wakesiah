defmodule WakesiahTest.StartTests do
  use ExUnit.Case, async: false

  test "start_link with name option" do
    {:ok, pid} = Wakesiah.start_link name: :test
    try do
      assert Process.whereis(:test) == pid
      assert {:links, [self]} == Process.info(pid, :links)
    after
      Wakesiah.stop pid
    end
  end

  test "start_link without name option" do
    assert {:ok, pid} = Wakesiah.start_link
    assert {:registered_name, []} == Process.info(pid, :registered_name)
    assert {:links, [self]} == Process.info(pid, :links)
  end

  test "start with name option" do
    {:ok, pid} = Wakesiah.start name: :test
    try do
      assert Process.whereis(:test) == pid
      assert {:links, []} == Process.info(pid, :links)
    after
      Wakesiah.stop pid
    end
  end

  test "start without name option" do
    {:ok, pid} = Wakesiah.start
    assert {:links, []} == Process.info(pid, :links)
  end

end
