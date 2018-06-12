namespace :db do
  require 'sequel'

  def connect
    return @db unless @db.nil?
    database_url = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : 'postgres://postgres:postgres@localhost:5432/oslobysykkel'
    return Sequel.connect(database_url)
  end

  desc 'Prints current schema version'
  task :version do
    Sequel.extension :migration
    @db = connect
    version = if @db.tables.include?(:schema_info)
                @db[:schema_info].first[:version]
              end || 0

    puts "Schema Version: #{version}"
  end

  desc 'Perform migration up to latest migration available'
  task :migrate do
    Sequel.extension :migration
    @db = connect
    Sequel::Migrator.run(@db, './db/migrations')
    Rake::Task['db:version'].execute
  end

  desc 'Perform rollback to specified target or full rollback as default'
  task :rollback, :target do |_t, args|
    Sequel.extension :migration
    @db = connect
    args.with_defaults(target: 0)

    Sequel::Migrator.run(@db, './db/migrations', target: args[:target].to_i)
    Rake::Task['db:version'].execute
  end

  desc 'Perform migration reset (full rollback and migration)'
  task :reset do
    Sequel.extension :migration
    @db = connect
    Sequel::Migrator.run(@db, './db/migrations', target: 0)
    Sequel::Migrator.run(@db, './db/migrations')
    Rake::Task['db:version'].execute
  end
end
