# APMap

A drag-and-drop access point wonderland for keeping track of your network.

This version of APMap was built using Rails 4.2.3 and Ruby 2.2.2. It should run on Ruby versions back to 1.9.3.

## System dependencies

All of the gems inside of the Gemfile are required in order to run. You can run `bundle install` from the app root folder to resolve these dependencies.

## Configuration

Before running, ensure that config/database.yml is configured to be able to connect to your database. In particular, set the username and password to match your database configuration, and set the database names. Then from the app root folder, do `rake db:schema:load` for the database structure.

For LDAP authentication, set the config.x.ldap variables in config/application.rb to match your server.

## Running

A server start script is provided in scripts/ that can be placed in /etc/rc.d/.

To run the server, do `/etc/rc.d/rc.apmap.new start`, with an optional port (3000 by default.)

To stop the server, do `/etc/rcd./rc.apmap.new stop`.