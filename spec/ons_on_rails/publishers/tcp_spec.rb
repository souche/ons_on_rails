require 'rails_helper'

RSpec.describe OnsOnRails::Publishers::Tcp do
  let(:backend) { :tcp }
  let(:publisher) do
    options = OnsOnRails.ons_default_options
    options = options.slice(:access_key, :secret_key).merge(options.fetch(:user_service_publisher))
    OnsOnRails::Publisher.new(backend, options)
  end

  let(:deliveries) { [] }
  before do
    allow(publisher.instance_variable_get('@backend').instance_variable_get('@client'))
      .to receive(:send_message)
        .and_wrap_original { |_method, *args| deliveries << { topic: args[0], tag: args[1], body: args[2], key: args[3] } }
  end

  it_should_behave_like 'a publisher'
end
