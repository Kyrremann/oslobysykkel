require 'http'
require 'json'

require_relative 'models/init'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

def get_bike_availability
  http = HTTP
           .headers('Client-Identifier': "#{ENV['BYSYKKEL_TOKEN']}")
  response = http.get("#{ENV['BYSYKKEL_URL']}/stations/availability")
  if response.status.ok?
    JSON.parse(response.to_s)
  else
    p response
    nil
  end
end

def main
  json = get_bike_availability
  return unless json
  http = HTTP.basic_auth(user: ENV['CORLYSIS_USER'], pass: ENV['CORLYSIS_PASSWORD'])

  updated_at = json['updated_at']
  stations = json['stations']
  p "Have #{stations.length} stations to POST"
  stations.each do |data|
    id = data['id']
    name = Station.find(station_id: id)
    unless name
      p "No station with id #{id}"
      next
    end

    bikes = data['availability']['bikes']
    locks = data['availability']['locks']

    res = http.post("#{ENV['CORLYSIS_SERVER']}/write?db=#{ENV['CORLYSIS_DATABASE']}",
                    body: "bysykkel,station_name=#{name},station_id=#{id},type=bikes value=#{bikes}")
    p unless res.status.success?
    
    res = http.post("#{ENV['CORLYSIS_SERVER']}/write?db=#{ENV['CORLYSIS_DATABASE']}",
              body: "bysykkel,station_name=#{name},station_id=#{id},type=locks value=#{locks}")
    p unless res.status.success?
  end
end

p "Running new job"
main
p "Done"
