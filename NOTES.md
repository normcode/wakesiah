wakesiah: development notest
============================

Setting up nodes:

    $ iex --sname node1 -S mix
    iex(node1@wakesiah-dev)> {:ok, pid} = Wakesiah.start {:global, :foo}


    $ iex --sname node2 -S mix
    iex(node2@wakesiah-dev)> {:ok, pid} = Wakesiah.start :bar
    iex(node2@wakesiah-dev)> :ok = Wakesiah.connect pid, [{:global, :foo}]

