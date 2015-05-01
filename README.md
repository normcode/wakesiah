wakesiah: Process Group Membership
==================================

This project is a gossip-based membership service implemented in
Elixir.

It is personal research project and is not fit for any purpose.

If you want to learn with me, I welcome any contribution including
feedback, questions, issues, documentation, gifs, and code. You're
always free to email me.

Development
-----------

You can run the unit tests with:

    $ mix test

Or you can start a shell and explore:

    $ iex --sname shortname -S mix

### Development environment ###

There is a [Vagrant](https://www.vagrantup.com) configuration that
will provision a virtual machine for development purposes.

To create the development environment:

    $ vagrant up

Once the virtual machine is created and configured, you can login:

    $ vagrant ssh

You'll find the source code in `/vagrant` on the vm.

### Local development ###

Of course, you can do your development on your own workstation if you
like. You'll need to install the following dependencies:

- elixir v1.0.0 or later
  [available here](https://www.erlang-solutions.com/downloads/download-elixir)
- erlang/OTP R17.0 or later
  [available here](https://www.erlang-solutions.com/downloads/download-erlang-otp)
