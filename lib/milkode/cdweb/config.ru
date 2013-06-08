require './app'

run Sinatra::Application
# run Rack::URLMap.new("/sub" => Sinatra::Application)

