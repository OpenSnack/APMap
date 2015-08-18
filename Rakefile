# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :create_empty_schema do
    sql = File.open("db/schema.sql").read
    sql.split(';').each do |sql_statement|
        ActiveRecord::Base.connection.execute(sql_statement)
    end
  puts "Empty Schema has been created '#{Time.now}' "
end