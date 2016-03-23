@directory = File.expand_path(File.dirname(__FILE__))

worker_processes 5
working_directory @directory

timeout 30

# set process id path
pid "#{@directory}/tmp/pids/unicorn.pid"

# set log file paths
stderr_path "#{@directory}/log/unicorn.stderr.log"
stdout_path "#{@directory}/log/unicorn.stdout.log"
