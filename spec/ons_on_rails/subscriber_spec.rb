require 'rails_helper'

RSpec.describe OnsOnRails::Subscriber do
  let(:subscriber) { Class.new { include OnsOnRails::Subscriber } }

  describe '.ons_options' do
    it 'could set ons options' do
      subscriber.ons_options access_key: 'ak-12u309', secret_key: 'sk-n120as',
                             consumer_id: 'consumer_id-130ujn', topic: 'topic-123has', tag: 'tag-m234hi'

      expect(subscriber.ons_options.fetch(:access_key)).to eq('ak-12u309')
      expect(subscriber.ons_options.fetch(:secret_key)).to eq('sk-n120as')
      expect(subscriber.ons_options.fetch(:consumer_id)).to eq('consumer_id-130ujn')
      expect(subscriber.ons_options.fetch(:topic)).to eq('topic-123has')
      expect(subscriber.ons_options.fetch(:tag)).to eq('tag-m234hi')
    end
  end

  describe '.consume' do
    let(:message) { { topic: 'topic', tag: 'tag', body: 'moasd1' } }

    it 'creates a new instance and invoke its #consume method' do
      messages = []
      subscriber.class_exec { define_method(:consume) { |message| messages << message } }

      subscriber.consume(message)
      expect(messages).to match_array([message])
    end

    it 'returns true when all work fine' do
      subscriber.class_exec { define_method(:consume) { |_message| nil } }

      r = subscriber.consume(message)
      expect(r).to be_truthy
    end

    it 'returns false when error raised' do
      subscriber.class_exec { define_method(:consume) { |_message| raise } }

      silence_logger(OnsOnRails.logger) do
        r = subscriber.consume(message)
        expect(r).to be_falsy
      end
    end
  end

  describe '.check_subscriber_definition!' do
    it 'not raise error when all work fine' do
      subscriber.class_exec do
        ons_options access_key: 'ak', secret_key: 'sk', consumer_id: 'cid', topic: 'topic', tag: 'tag'
        define_method(:consume) { |_message| nil }
      end

      expect { subscriber.check_subscriber_definition! }.not_to raise_error
    end

    it 'raise error when missing required ons options' do
      expect { subscriber.check_subscriber_definition! }.to raise_error(/missing key/)
    end

    it 'raise error when missing required method' do
      subscriber.ons_options access_key: 'ak', secret_key: 'sk', consumer_id: 'cid', topic: 'topic', tag: 'tag'
      expect { subscriber.check_subscriber_definition! }.to raise_error(/method #consume not implemented/)
    end
  end
end
