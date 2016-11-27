require 'bundler/setup'

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec do
  Rails.env = 'test'
  Rake::Task['app:db:environment:set'].invoke if Rails::VERSION::MAJOR == 5
  Rake::Task['app:db:drop'].invoke
  Rake::Task['app:db:create'].invoke
  Rake::Task['app:db:schema:load'].invoke
end

task default: :spec
