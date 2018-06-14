require 'haml'
require 'http'
require 'json'
require 'sinatra'

require_relative 'models/init'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

get '/status' do
  http = HTTP
           .headers('Client-Identifier': "#{ENV['BYSYKKEL_TOKEN']}")
  response = http.get("#{ENV['BYSYKKEL_URL']}/status")
  if response.status.ok?
    status = JSON.parse(response.to_s)['status']
    haml(:status, locals: { status: status })
  else
    response
  end
end

get '/:station_id' do |station_id|
  station = Station.find(station_id: station_id)
  haml(:station, locals: { station: station })
end

get '/' do
  haml(:index)
end
