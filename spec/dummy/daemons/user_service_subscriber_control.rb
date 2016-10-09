require 'rubygems'
require 'ons_on_rails'

APP_PATH = File.expand_path('../..', __FILE__)
OnsOnRails.run_subscriber_as_a_daemon(:user_service_subscriber, APP_PATH)
