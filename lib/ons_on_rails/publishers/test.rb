module OnsOnRails
  module Publishers
    class Test
      def initialize(_options)
      end

      def publish(topic, tag, body, key)
        Publisher.deliveries << { topic: topic, tag: tag, body: body, key: key }
      end
    end
  end
end
