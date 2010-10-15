require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/session'
require 'rack-flash'
require 'digest/sha2'
require 'mongo_mapper'
require 'hpricot'
require 'open-uri'
require 'uri'
require 'id3lib'
require 'net/http'
require 'socket'
require 'json'
require './database.rb'
require './helpers.rb'



use Rack::Session::Cookie
use Rack::Flash
set :session_fail, '/login'
set :session_secret, '33tcak3&d13!'
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'



# -------- URL ROUTING -------- #


get '/admin' do
  @users = User.all()
  erb :admin
end

get '/admin/delete/:id' do
    User.destroy(params[:id]);
    redirect '/admin'
end

# return json object for all mp3s
get '/all.json' do
  content_type :json
  @mp3_files = Mp3File.all()
  return @mp3_files.to_json
end

# return json object for all mp3s
get '/fav.json' do
  content_type :json
  @mp3_files = Mp3File.all(:favourite => true)
  return @mp3_files.to_json
end

get '/users.json' do
  content_type :json
  users = User.all()
  return users.to_json
end

get '/blogs.json' do
  content_type :json
  blogs = Blog.all()
  return blogs.to_json
end

# login
get '/login' do
  if session?
    redirect '/'
  else
    erb :login
  end
end

post '/login' do
  user = User.find(params[:username].chomp)
  if user && user.password.eql?(hash_password(user.timestamp, params[:password]))
    session_start!
    session[:name] = user._id
    flash[:notice] = "Welcome #{session[:name]}!"
    redirect '/'
  else
    flash.now[:notice] = "There was an error loging in" 
    erb :login
  end
end

# logout
get '/logout' do
  session_end!
  redirect '/'
end

# signup
get '/signup' do
  erb :signup
end

post '/signup' do
  current_time = Time.now.to_s
  user = User.create({
    :_id => params[:username].chomp,
    :fullname => params[:fullname].chomp, 
    :password => hash_password(current_time, params[:password].chomp), 
    :email => params[:email].chomp,
    :timestamp => current_time
  }) unless User.find(params[:username].chomp) or User.exists?(:email => params[:email].chomp)

  begin
    if user.save
      redirect '/login'
    else 
      @error = true
      erb :signup
    end
  rescue
    @duplicate = true
    erb :signup
  end
end


# Show all favourited mp3s
get '/' do
  unless session?
    erb :index
  else
    @mp3_files = Mp3File.all()
    erb :home
  end
end


get '/home' do
  session!
  @mp3_files = Mp3File.all()
  erb :home
end


get '/favourite/:id' do
  session!
  user = User.find(session[:name])
  user.fav_mp3s << params[:id]
  user.save
end


get '/unfavourite/:id' do
  session!
  user = User.find(session[:name])
  user.fav_mp3s.reject! { |id| id =~ params[:id] }
  user.save
end


# list list all blogs
get '/blogs' do
  session!
  @blogs = Blog.all()
  erb :blogs
end


# add blog to list
post '/blogs' do
  url = params[:new_url].chomp("/")
  scrape = Hpricot(open(url))
  title = scrape.search('title').inner_text
  resp = Net::HTTP.get_response(URI.parse(url))
  last_modified = resp["last-modified"] 

  new_blog = Blog.create({:url => params[:new_url], :name => title, :date => last_modified})

  if new_blog.save
    redirect '/blogs' 
  else
    redirect '/blogs' 
  end
end

# remove blog from sources
get '/blogs/delete/:id' do
    Blog.destroy(params[:id]);
    redirect '/blogs'
end

#Show all mp3s
get '/:username' do
  if User.find(params[:username])
    @mp3_files = Mp3File.all()
    @user = params[:username]
    erb :user_playlist
  else    
    not_found
  end
end


not_found do
  erb :error, :layout => false
end


Sinatra::Application.run!
