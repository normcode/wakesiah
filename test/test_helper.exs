exclude = [distributed: not Node.alive?]

File.rm("logs/test.log")

ExUnit.start(exclude: exclude)
