RSpec.shared_examples 'a publisher' do |_params|
  describe '.initialize' do
    it 'creates a new instance' do
      options = OnsOnRails.ons_default_options
      options = options.slice(:access_key, :secret_key).merge(options.fetch(:user_service_publisher))
      expect { OnsOnRails::Publisher.new(backend, options) }.not_to raise_error
    end

    it 'raises error when missing required key' do
      options = OnsOnRails.ons_default_options
      options = options.slice(:access_key, :secret_key).merge(options.fetch(:user_service_publisher))
      %i(access_key secret_key producer_id topic tag).each do |required_key|
        incomplete_options = options.reject { |opt| opt == required_key }
        expect { OnsOnRails::Publisher.new(backend, incomplete_options) }.to raise_error(/key not found: :#{required_key}/)
      end
    end
  end

  describe '#publish' do
    it 'publishs a message' do
      data = { operate: :create, user: { id: '123456lkjhgf' } }
      expect { publisher.publish(data) }.to change { deliveries.size }.by(1)
      expect(deliveries.last).to eq(topic: ENV['ONS_TOPIC'], tag: 'user_service', body: data.to_json, key: '')
    end

    it 'overwrites the message :topic' do
      expect { publisher.publish({}, topic: 'topic-21u09u4234') }.to change { deliveries.size }.by(1)
      expect(deliveries.last.fetch(:topic)).to eq('topic-21u09u4234')
    end

    it 'overwrites the message :tag' do
      expect { publisher.publish({}, tag: 'tag-ap123sd') }.to change { deliveries.size }.by(1)
      expect(deliveries.last.fetch(:tag)).to eq('tag-ap123sd')
    end

    it 'treats the message body as :json data' do
      data = { operate: :create, user: { id: '123456lkj123' } }
      expect { publisher.publish(data, foramt: :json) }.to change { deliveries.size }.by(1)
      expect(deliveries.last.fetch(:body)).to eq(data.to_json)
    end

    it 'treats the message body as :raw data' do
      data = { operate: :create, user: { id: '1213js9kj123' } }.to_json
      expect { publisher.publish(data, format: :raw) }.to change { deliveries.size }.by(1)
      expect(deliveries.last.fetch(:body)).to eq(data)
    end
  end
end
