@directory = File.expand_path(".")

working_directory @directory

worker_processes 5
timeout 30

# set process id path
pid "#{@directory}/tmp/pids/unicorn.pid"
# set socket file
listen "#{@directory}/tmp/sockets/unicorn.sock", backlog: 64

# set log file paths
stderr_path "#{@directory}/log/unicorn.stderr.log"
stdout_path "#{@directory}/log/unicorn.stdout.log"
