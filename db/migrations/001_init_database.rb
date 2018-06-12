Sequel.migration do
  change do
    create_table(:stations) do
      primary_key :id
      Int :station_id, null: false
      String :title, null: false
      String :subtitle, null: false
      Int :number_of_locks, null: false

      Time :created_at, null: false
      Time :updated_at
    end
  end
end
