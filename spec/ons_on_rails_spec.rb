require 'rails_helper'

RSpec.describe OnsOnRails do
  describe '.logger' do
    let(:logger) { described_class.logger }

    it 'is a Logger instance' do
      expect(logger).to be_kind_of(::Logger)
    end
  end

  describe '.ons_default_options' do
    let(:options) { described_class.ons_default_options }

    it 'initializes default options from file config/ons_on_rails.yml' do
      expect(options).to have_key(:access_key)
      expect(options).to have_key(:secret_key)
      expect(options).to have_key(:user_service_subscriber)
      expect(options.fetch(:user_service_subscriber).fetch(:tag)).to eq('user_service')
    end

    it 'treats config/ons_on_rails.yml as an ERB file' do
      expect(options.fetch(:rspec_erb)).to eq('ERB')
    end

    it 'uses the proper section according to Rails.env' do
      expect(options).to have_key(:rspec_rails_env)
      expect(options.fetch(:rspec_rails_env)).to eq('test')
    end
  end
end
