defmodule Wakesiah.Group do

  @name __MODULE__

  def start_link(options \\ [name: @name])
  def start_link(options) do
    Agent.start_link(fn -> HashDict.new end, options)
  end

  def join(group) when is_bitstring(group), do: join(@name, group, self)

  def join(group, member) when is_bitstring(group) and is_pid(member) do
    join(@name, group, member)
  end

  def join(pid, group) when is_bitstring(group), do: join(pid, group, self)

  def join(pid, group, member) when is_bitstring(group) and is_pid(member) do
    Agent.update(pid, &add_member(&1, group, member))
  end

  defp add_member(state, group, member) do
    default = Enum.into([member], HashSet.new)
    Dict.update(state, group, default, &Set.put(&1, member))
  end

  def leave(group) when is_bitstring(group), do: leave(@name, group, self())
  def leave(pid, group, member \\ self) do
    Agent.update(pid, &remove_member(&1, group, member))
  end

  defp remove_member(state, group, member)
  when is_bitstring(group) and is_pid(member) do
    default = HashSet.new
    Dict.update(state, group, default, &Set.delete(&1, member))
  end

  def delete(group) when is_bitstring(group), do: delete(@name, group)
  def delete(pid, group) when is_bitstring(group) do
    Agent.update(pid, &delete_group(&1, group))
  end

  defp delete_group(state, group) do
    Dict.delete(state, group)
  end

  def members(group), do: members(@name, group)
  def members(pid, group) when is_bitstring(group) do
    Agent.get(pid, &get_members(&1, group))
  end

  defp get_members(state, group) do
    Dict.get(state, group, HashSet.new) |> HashSet.to_list
  end

  def value(), do: value(@name)
  def value(pid) do
    Agent.get(pid, &get_value(&1))
  end

  defp get_value(state), do: state

end
