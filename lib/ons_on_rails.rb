require 'active_support/all'
require 'daemons'

require 'ons_on_rails/publisher'
Dir[File.expand_path('../ons_on_rails/publishers/*', __FILE__)].each { |f| require f }

require 'ons_on_rails/subscriber'
require 'ons_on_rails/version'

# .
module OnsOnRails
  # Get the global logger.
  def self.logger
    @logger ||= initialize_logger
  end

  # Initialize an logger instance.
  def self.initialize_logger
    require 'logger'
    Logger.new(STDOUT)
  end
  private_class_method :initialize_logger

  # Get the ons default options.
  def self.ons_default_options
    @ons_default_options ||= initialize_ons_default_options
  end

  # Try to load ons options from config/ons_on_rails.yml.
  def self.initialize_ons_default_options
    return {} unless defined?(::Rails)

    file = ::Rails.root.join('config', 'ons_on_rails.yml')
    return {} unless file.exist?

    require 'erb'
    require 'yaml'
    opts = YAML.load(ERB.new(IO.read(file)).result) || {}
    opts.deep_symbolize_keys.fetch(::Rails.env.to_sym, {})
  end
  private_class_method :initialize_ons_default_options

  # Create a Publisher.
  #
  # @param publisher_name [Symbol, String] the publisher's name
  # @param backend [#to_s] backend name, such as :tcp, :test, etc.
  #
  # @see OnsOnRails::Publisher
  def self.create_publisher(publisher_name, backend: :tcp)
    options ||= begin
      opts = OnsOnRails.ons_default_options
      opts.slice(:access_key, :secret_key).merge(opts.fetch(publisher_name.to_s.underscore.to_sym, {}))
    end

    OnsOnRails::Publisher.new(backend, options)
  end

  # Run a subscriber as a separate process.
  #
  # @param subscriber_class_name [Symbol, String] the subscriber's class name
  # @param app_path [String] the Rails root directory path
  def self.run_subscriber_as_a_daemon(subscriber_class_name, app_path)
    options = { daemon_name: subscriber_class_name.to_s.underscore }
    run_multi_subscriber_as_a_daemon(Array(subscriber_class_name), app_path, options)
  end

  # Run multi-subscribers as a separate process.
  #
  # @param subscriber_class_name_array [Array<Symbol, String>] the array of subscriber's class name
  # @param app_path [String] the Rails root directory path
  # @param options [Hash]
  # @option options [String] :daemon_name ('subscribers') The name of the daemon. This will be used to contruct the name of the pid files and log files
  def self.run_multi_subscriber_as_a_daemon(subscriber_class_name_array, app_path, options = {})
    daemon_name = options.fetch(:daemon_name, 'subscribers')
    daemon_options = {
      backtrace: true,
      dir_mode: :normal,
      dir: File.join(app_path, 'tmp', 'pids'),
      log_dir: File.join(app_path, 'log'),
      log_output: true
    }

    Daemons.run_proc(daemon_name, daemon_options) do
      require File.join(app_path, 'config', 'environment') unless defined?(::Rails)
      require 'ons' unless defined?(Ons)

      subscriber_class_name_array.each do |subscriber_class_name|
        subscriber_class_name = subscriber_class_name.to_s.camelize
        subscriber_class = subscriber_class_name.constantize
        subscriber_class.check_subscriber_definition!

        options = subscriber_class.ons_options
        Ons::Consumer.new(options.fetch(:access_key), options.fetch(:secret_key), options.fetch(:consumer_id))
                     .subscribe(options.fetch(:topic), options.fetch(:tag), &->(message) { subscriber_class.consume(message) })
                     .start
      end

      Ons.register_cleanup_hooks
      Ons.loop_forever
    end
  end
end
