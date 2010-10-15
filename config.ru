require './application.rb'

use Rack::Session::Cookie
use Rack::Flash
set :session_fail, '/login'
set :session_secret, '33tcak3&d13!'
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'
    
run Sinatra::Application


