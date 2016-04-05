require 'sinatra/base'
require 'sinatra/activerecord'
require 'slim'
require 'digest/sha1'

APP_ROOT = File.expand_path('.')
UPLOADS_DIR = File.join(APP_ROOT, 'public', 'uploads')

class User < ActiveRecord::Base
  validates_presence_of :name

  def avatar_url
    ['uploads', avatar_file].join(?/)
  end
end

UploadedFile = Struct.new(:file_params) do
  def name
    [sha, extension].join(?.)
  end

  def temp_file
    file_params[:tempfile]
  end

  def extension
    file_params[:filename].split(?.).last
  end

  def content
    @content ||= temp_file.read
  end

  def sha
    Digest::SHA1.hexdigest content
  end

  def path
    File.join(UPLOADS_DIR, name)
  end

  def save
    File.open(path, 'w') do |file|
      file.write(content)
    end
  end
end

class MyApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database_file, File.join(APP_ROOT, 'config', 'database.yml')

  helpers do
    def user_params
      params[:user]
    end
  end

  get '/' do
    @users = User.all
    slim :index
  end

  post '/users' do
    if user_params[:file]
      file = UploadedFile.new(user_params[:file])
      User.create(name: user_params[:name], avatar_file: file.name) if file.save
    end
    redirect to('/')
  end
end
