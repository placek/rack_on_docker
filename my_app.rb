require 'sinatra/base'
require 'sinatra/activerecord'
require 'slim'

class User < ActiveRecord::Base
  validates_presence_of :name
end

class MyApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database_file, File.expand_path('./config/database.yml')

  get '/' do
    @users = User.all
    slim :index
  end
end
