module OnsOnRails
  module Publishers
    class Tcp
      def initialize(options)
        @client = Ons::Producer.new(options.fetch(:access_key), options.fetch(:secret_key), options.fetch(:producer_id))
        @client.start
      end

      def publish(topic, tag, body, key)
        @client.send_message(topic, tag, body, key)
      end
    end
  end
end
