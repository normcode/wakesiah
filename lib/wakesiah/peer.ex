defmodule Wakesiah.Peer do

  use Fsm, initial_state: :alive, initial_data: 0

  def new(attrs) do
    state = Keyword.get(attrs, :state, :alive)
    inc = Keyword.get(attrs, :data, 0)
    %__MODULE__{state: state, data: inc}
  end

  defstate alive do
    defevent alive(i), data: j, when: i > j do
      next_state(:alive, i)
    end

    defevent alive(_) do
      next_state(:alive)
    end

    defevent suspect(i), data: j, when: i >= j do
      next_state(:suspect, i)
    end

    defevent suspect(_) do
      next_state(:alive)
    end

    defevent confirm(i) do
      next_state(:failed, i)
    end

  end

  defstate suspect do
    defevent alive(i), data: j, when: i > j do
      next_state(:alive, i)
    end

    defevent suspect(i), data: j, when: i > j do
      next_state(:suspect, i)
    end

    defevent confirm(i) do
      next_state(:failed, i)
    end

    defevent _ do
      next_state(:suspect)
    end

  end

  defstate failed do
    defevent _ do
      next_state(:failed)
    end
  end

end
