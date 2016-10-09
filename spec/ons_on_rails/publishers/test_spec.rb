require 'rails_helper'

RSpec.describe OnsOnRails::Publishers::Test do
  let(:backend) { :test }
  let(:publisher) do
    options = OnsOnRails.ons_default_options
    options = options.slice(:access_key, :secret_key).merge(options.fetch(:user_service_publisher))
    OnsOnRails::Publisher.new(backend, options)
  end

  let(:deliveries) { OnsOnRails::Publisher.deliveries }

  it_should_behave_like 'a publisher'
end
