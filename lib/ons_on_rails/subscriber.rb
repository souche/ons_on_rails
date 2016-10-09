module OnsOnRails
  # .
  module Subscriber
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Allows customization for this type of subscriber.
      #
      # @param options [Hash{String, Symbol => String}]
      # @option options [String] :access_key the access key to aliyun ONS
      # @option options [String] :secret_key the secret key to aliyun ONS
      # @option options [String] :consumer_id the consumer ID
      # @option options [String] :topic the message topic
      # @option options [String] :tag the subscribe expression used to filter messages
      def ons_options(options = {})
        @ons_options ||= begin
          opts = OnsOnRails.ons_default_options
          opts.slice(:access_key, :secret_key).merge(opts.fetch(name.to_s.underscore.to_sym, {}))
        end

        return @ons_options if options.blank?
        @ons_options.merge!(options.symbolize_keys)
      end

      # Create a new subscriber instance to consume the incoming message.
      #
      # @param message [Hash{Symbol => Object}]
      # @option message [String] topic, the message topic
      # @option message [String] tag, the message tag
      # @option message [String] body, the message body
      # @option message [String] id, the message id
      # @option message [String] key, the message key
      # @return [Boolean] true/CommitMessage or false/ReconsumeLater
      def consume(message)
        new.consume(message)
        true
      rescue => ex
        OnsOnRails.logger.error ex.message
        OnsOnRails.logger.error ex.backtrace.join("\n")
        false
      end

      # Determine whether it is a valid subscriber or not.
      def check_subscriber_definition!
        keys = %i(access_key secret_key consumer_id topic tag)
        keys.each { |key| raise "missing key :#{key} in ons options" unless ons_options.key?(key) }
        raise 'method #consume not implemented' unless instance_methods(false).include?(:consume)
      end
    end
  end
end
