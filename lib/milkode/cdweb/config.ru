require './app'

map (ENV['MILKODE_RELATIVE_URL'] || '/') do
  run Sinatra::Application
end

