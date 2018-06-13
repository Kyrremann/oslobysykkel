require 'haml'
require 'sinatra'

require_relative 'models/init'

get '/:station_id' do |station_id|
  station = Station.find(station_id: station_id)
  haml(:station, locals: { station: station })
end

get '/' do
  haml(:index)
end
