defmodule WakesiahTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Wakesiah.start_link name: __MODULE__
    {:ok, [pid: pid]}
  end
  
  test "membership list is empty on start", %{pid: pid} do
    assert Wakesiah.members(pid) == []
  end
end
