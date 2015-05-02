defmodule WakesiahTest.StartTests do
  use ExUnit.Case, async: true

  test "start_link with name option" do
    {:ok, pid} = Wakesiah.start_link nil, name: :test
    try do
      assert Process.whereis(:test) == pid
      assert {:links, [self]} == Process.info(pid, :links)
    after
      Wakesiah.stop pid
    end
  end

  test "start_link without name option" do
    assert {:ok, pid} = Wakesiah.start_link nil
    assert {:links, [self]} == Process.info(pid, :links)
  end

  test "start with name option" do
    {:ok, pid} = Wakesiah.start nil, name: :test
    try do
      assert Process.whereis(:test) == pid
      assert {:links, []} == Process.info(pid, :links)
    after
      Wakesiah.stop pid
    end
  end

  test "start without name option" do
    {:ok, pid} = Wakesiah.start nil
    assert {:links, []} == Process.info(pid, :links)
  end
end
