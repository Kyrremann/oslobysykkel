require 'sequel'

Sequel::Model.plugin :timestamps

database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/oslobysykkel'
DB = Sequel.connect(database_url)

require_relative 'station'
