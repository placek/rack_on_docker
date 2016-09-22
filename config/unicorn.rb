working_directory ENV['APP_DIRECTORY']
pid               ENV['UNICORN_PID_FILE']
worker_processes  ENV['UNICORN_WORKER_PROCESSES'].to_i
timeout           ENV['UNICORN_TIMEOUT'].to_i
stdout_path       ENV['UNICORN_STDOUT_LOG_FILE']
stderr_path       ENV['UNICORN_STDERR_LOG_FILE']
