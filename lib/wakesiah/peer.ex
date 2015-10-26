defmodule Wakesiah.Peer do

  use Fsm, initial_state: :alive, initial_data: 0

  def new(attrs) do
    state = Keyword.get(attrs, :state, :alive)
    inc = Keyword.get(attrs, :data, 0)
    %__MODULE__{state: state, data: inc}
  end

  defstate alive do
    defevent alive(i), data: j, when: i > j do
      respond([], :alive, i)
    end

    defevent alive(_) do
      respond([], :alive)
    end

    defevent suspect(i), data: j, when: i >= j do
      respond([], :suspect, i)
    end

    defevent suspect(_) do
      respond([], :alive)
    end

    defevent failed(i) do
      respond([], :failed, i)
    end

  end

  defstate suspect do
    defevent alive(i), data: j, when: i > j do
      respond([], :alive, i)
    end

    defevent suspect(i), data: j, when: i > j do
      respond([], :suspect, i)
    end

    defevent failed(i) do
      respond([], :failed, i)
    end

    defevent _ do
      respond([], :suspect)
    end

  end

  defstate failed do
    defevent _ do
      respond([], :failed)
    end
  end

end
