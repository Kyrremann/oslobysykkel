require 'http'
require 'json'

require_relative 'models/init'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

def influxlize_value(str)
  str = str.gsub('Æ', 'AE')
  str = str.gsub('æ', 'ae')
  str = str.gsub('Ø', 'OE')
  str = str.gsub('ø', 'oe')
  str = str.gsub('Å', 'AA')
  str = str.gsub('å', 'aa')
  str = str.gsub(' ', '\ ')
  str = str.gsub('é', 'e')
  str = str.gsub('ü', 'u')
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
    station = Station.find(station_id: id)
    unless station
      p "No station with id #{id}"
      p data
      next
    end

    name = influxlize_value(station.title)
    bikes = data['availability']['bikes']
    locks = data['availability']['locks']

    body = "bysykkel,station_name=#{name},station_id=#{id},type=bikes value=#{bikes}"
    res = http.post("#{ENV['CORLYSIS_SERVER']}/write?db=#{ENV['CORLYSIS_DATABASE']}",
                    body: body)
    unless res.status.success?
      p res
      p body
    end

    body = "bysykkel,station_name=#{name},station_id=#{id},type=locks value=#{locks}"
    res = http.post("#{ENV['CORLYSIS_SERVER']}/write?db=#{ENV['CORLYSIS_DATABASE']}",
                    body: body)
    unless res.status.success?
      p res
      p body
    end
  end
end

p "Running new job"
main
p "Done"
