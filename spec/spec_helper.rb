ENV["RAILS_ENV"] = "test"
require 'spec'
require 'action_controller'
require 'lib/polyparent'
require 'active_record'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['sqlite3mem'])

ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/schema.rb")

class Shoe < ActiveRecord::Base; end
class ShoeString < Shoe; end

class User < ActiveRecord::Base; end
class Animal < ActiveRecord::Base; end

Spec::Runner.configure do |config|
end

