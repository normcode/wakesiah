wakesiah: development notest
============================

Setting up nodes:

    $ iex --sname node1 -S mix
    iex(node1@wakesiah-dev)> {:ok, pid} = Wakesiah.start_link Wakesiah
    {:ok, #PID<0.107.0>}
    iex(node1@wakesiah-dev)> Wakesiah.members pid
    []

The above starts a new Wakesiah server named `Wakesiah`. Mix starts
the OTP application which registers a process with the name
`:wakesiah`.

    iex(node1@wakesiah-dev)> Process.whereis :wakesiah |> Process.info
    [registered_name: :wakesiah, current_function: {:gen_server, :loop, 6},
     initial_call: {:proc_lib, :init_p, 5}, status: :waiting, message_queue_len: 0,
     messages: [], links: [#PID<0.91.0>],
     dictionary: ["$ancestors": [#PID<0.91.0>, #PID<0.90.0>],
      "$initial_call": {Wakesiah, :init, 1}], trap_exit: false,
     error_handler: :error_handler, priority: :normal, group_leader: #PID<0.89.0>,
     total_heap_size: 1363, heap_size: 987, stack_size: 9, reductions: 29752,
     garbage_collection: [min_bin_vheap_size: 46422, min_heap_size: 233,
      fullsweep_after: 65535, minor_gcs: 79], suspending: []]

To connect to a remote wakesiah process:

    $ iex --sname node2 -S mix
    iex(node2@wakesiah-dev)> Wakesiah.connect :"node1@wakesiah-dev"}
    {:ok, :connected}
    iex(node2@wakesiah-dev)> Wakesiah.members :wakesiah
    [:"node2@wakesiah-dev"]
    
To run distributed tests, start background node named `bar` and run
the tests in a node named `foo`:

    $ elixir --sname bar -S mix run --no-halt
    $ elixir --sname foo -S mix test

You can also use a remote shell to connect to the background node:

    $ iex --sname baz --remsh bar@wakesiah-dev
