require 'sinatra/base'
require 'sinatra/activerecord'
require 'slim'

class User < ActiveRecord::Base
  validates_presence_of :name
end

class MyApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :app_root, File.expand_path('.')
  set :database_file, File.join(settings.app_root, 'config', 'database.yml')

  get '/' do
    @users = User.all
    slim :index
  end
end
