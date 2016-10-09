# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ons_on_rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'ons_on_rails'
  spec.version       = OnsOnRails::VERSION
  spec.authors       = 'souche'

  spec.summary       = 'integrate the ons gem into a rails application'
  spec.homepage      = 'https://github.com/souche/ons_on_rails'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata) # rubocop: disable Style/GuardClause
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'daemons', '~> 1.2'
  spec.add_runtime_dependency 'activesupport', '>= 4.1'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.41'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.5'
  spec.add_development_dependency 'yard', '~> 0.9'

  # Rails dependency
  spec.add_development_dependency 'mysql2', '~> 0.3.13'
  spec.add_development_dependency 'ons', '~> 1.0.0'

  # Rails development dependency
  spec.add_development_dependency 'rspec-rails', '~> 3.5'
  spec.add_development_dependency 'database_cleaner', '~> 1.5'
end
