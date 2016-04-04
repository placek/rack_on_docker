require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require_relative 'my_app'
  end

  desc 'run irb console'
  task :console do
    exec 'irb -r irb/completion -r ' + File.expand_path('./my_app')
  end
end
