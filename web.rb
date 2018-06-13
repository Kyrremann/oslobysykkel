require 'sinatra'

require_relative 'models/init'

get '/' do
  haml(:index)
end
