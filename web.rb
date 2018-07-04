require 'haml'
require 'http'
require 'influxdb'
require 'json'
require 'sinatra'

require_relative 'models/init'

unless ENV['RACK_ENV'] == 'production'
  require 'dotenv/load'
end

url = 'https://token:36bc23251b8daa719ee14227c82715c4@corlysis.com:8086/oslobysykkel'
INFLUXDB = InfluxDB::Client.new(url: url)

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

get '/stations/:station_id' do |station_id|
  station = Station.find(station_id: station_id)

  yesterday = Date.today - 1
  dataset = INFLUXDB.query("select type, value from bysykkel where station_id = '#{station.station_id}' and time >= '#{yesterday.to_s}' tz('Europe/Oslo')")
  dataset = dataset.first['values']
  bikes = []
  locks = []
  time = []
  dataset.each do |data|
    type = data['type']
    if type == 'locks'
      locks << data['value']
    elsif type == 'bikes'
      bikes << data['value']
    end
    # we only need on set of times, so we skip times for locks
    time << DateTime.parse(data['time']).strftime('%H:%M') unless type == 'locks'
  end

  haml(:station, locals: { station: station,
                           time: time,
                           bikes: bikes,
                           locks: locks,
                           title: "#{station.station_id}: #{station.title}" })
end

get '/' do
  haml(:index)
end
