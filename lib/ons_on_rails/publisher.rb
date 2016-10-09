module OnsOnRails
  class Publisher
    # Create a Publisher.
    #
    # @param backend [#to_s] backend name, such as :tcp, :test, etc.
    # @param options [Hash{Symbol => String}]
    # @option options [String] :access_key the access key to aliyun ONS
    # @option options [String] :secret_key the secret key to aliyun ONS
    # @option options [String] :producer_id the producer ID
    # @option options [String] :topic the message topic
    # @option options [String] :tag the message tag
    def initialize(backend, options)
      required_keys = %i(access_key secret_key producer_id topic tag)
      required_keys.each { |required_key| options.fetch(required_key) }

      @default_topic = options.fetch(:topic)
      @default_tag = options.fetch(:tag)

      @backend_klass = OnsOnRails::Publishers.const_get(backend.to_s.camelize)
      @backend = @backend_klass.new(options.slice(:access_key, :secret_key, :producer_id))
    end

    # Publish a message.
    #
    # @param data [Hash, String] the data which will be converted to the message body
    # @param options [Hash{Symbol => String}]
    # @option options [String] :topic overwrite the message topic
    # @option options [String] :tag overwrite the message tag
    # @option options [String] :key the message key, useful when debug
    # @option options [String] :format('json') how convert the data to the message body, available format: 'json', 'raw', etc.
    # @return [void]
    def publish(data, options = {})
      topic = options.fetch(:topic, @default_topic)
      tag = options.fetch(:tag, @default_tag)

      format = options.fetch(:format, 'json').to_sym
      body =
        case format
        when :json then data.to_json
        when :raw then data.to_s
        else raise "unsupported message format #{format}"
        end

      @backend.publish(topic, tag, body, options.fetch(:key, ''))
    end

    # Keeps an array of all the messages published through the Publishers::Test backend. Most useful for unit and functional testing.
    def self.deliveries
      @deliveries ||= []
    end
  end
end
