require 'http'
require 'json'

require_relative 'models/init'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

def get_stations
    http = HTTP
           .headers('Client-Identifier': "#{ENV['BYSYKKEL_TOKEN']}")
  response = http.get("#{ENV['BYSYKKEL_URL']}/stations")
  if response.status.ok?
    JSON.parse(response.to_s)
  else
    p response
    nil
  end
end

def main
  json = get_stations
  return unless json

  stations = json['stations']
  stations.each do |station|
    id = station['id']
    next if Station.find(station_id: id)

    Station.create(station_id: id.to_i,
                   title: station['title'],
                   subtitle: station['subtitle'],
                   number_of_locks: station['number_of_locks'].to_i)
  end
end

main
