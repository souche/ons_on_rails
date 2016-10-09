class UserServiceSubscriber
  include OnsOnRails::Subscriber

  def consume(message)
    Rails.logger.debug "UserServiceSubscriber#consume: #{message}"
    data = JSON.parse(message.fetch(:body), symbolize_names: true)

    case data.fetch(:operate).to_sym
    when :create then User.create! data.fetch(:user).slice(:name)
    when :update then User.find(data.fetch(:id)).update!(data.fetch(:user).slice(:name))
    else raise
    end
  end
end
