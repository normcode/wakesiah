defmodule Wakesiah.GroupAgentTest do

  alias Wakesiah.Group

  use ExUnit.Case, async: true

  setup context do
    {:ok, process_group} = Wakesiah.Group.start_link(name: context.test)
    pid = spawn(fn -> :dummy end)
    {:ok, [process_group: process_group, pid: pid]}
  end

  test "stores a process", %{process_group: pgroup, pid: pid} do
    :ok = Group.join(pgroup, "group_name", pid)
    assert [pid] == Group.members(pgroup, "group_name")
  end

  test "stores a process, defaults to self", %{process_group: pgroup} do
    :ok = Group.join(pgroup, "group_name")
    assert [self()] == Group.members(pgroup, "group_name")
  end

  test "leave a group", %{process_group: pgroup, pid: pid} do
    :ok = Group.join(pgroup, "group_name", pid)
    :ok = Group.leave(pgroup, "group_name", pid)
    assert [] == Group.members(pgroup, "group_name")
  end

  test "leave a group, defaults to self", %{process_group: pgroup, pid: pid} do
    :ok = Group.join(pgroup, "group_name", self)
    :ok = Group.leave(pgroup, "group_name")
    assert [] == Group.members(pgroup, "group_name")
  end

  test "delete a group", %{process_group: pgroup, pid: pid} do
    :ok = Group.join(pgroup, "group_name", pid)
    :ok = Group.delete(pgroup, "group_name")
    assert [] == Group.members(pgroup, "group_name")
  end

  test "processes use default registered name", %{pid: pid} do
    {:ok, _} = Wakesiah.Group.start_link name: Wakesiah.Group
    :ok = Group.join("group_name")
    :ok = Group.join("group_name", pid)
    expected = [self, pid] |> Enum.into(HashSet.new) |> Set.to_list
    assert expected == Group.members("group_name")
  end

  test "gossip value", %{process_group: pgroup, pid: pid} do
    {:ok, _} = Wakesiah.Group.start_link name: Wakesiah.Group
    assert HashDict.new == Group.value(pgroup)
    :ok = Group.join(pgroup, "group_name", pid)
    :ok = Group.join("group_name", pid)
    assert Group.value(pgroup) == Group.value()
  end

end
