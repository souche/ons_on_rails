require 'rails_helper'

RSpec.describe 'Daemonize', type: :feature do
  before(:all) do
    Dir.chdir(::Rails.root) do
      `RAILS_ENV=#{::Rails.env} bundle exec ruby daemons/user_service_subscriber_control.rb stop`
      `rm -f tmp/pids/user_service_subscriber.pid`
      `rm -f log/user_service_subscriber.output`
      `RAILS_ENV=#{::Rails.env} bundle exec ruby daemons/user_service_subscriber_control.rb start`
    end
  end

  after(:all) do
    Dir.chdir(::Rails.root) do
      `RAILS_ENV=#{::Rails.env} bundle exec ruby daemons/user_service_subscriber_control.rb stop`
    end
  end

  it 'creates a pid file under tmp/pids/' do
    expect(::Rails.root.join('tmp', 'pids', 'user_service_subscriber.pid')).to be_exist
  end

  it 'creates a log file under log/' do
    expect(::Rails.root.join('log', 'user_service_subscriber.output')).to be_exist
  end

  it 'consumes messages' do
    $user_service_publisher.publish(operate: :create, user: { name: '123456lkjhgf' })
    wait_until(-> { User.where(name: '123456lkjhgf').exists? })
    expect(User.where(name: '123456lkjhgf')).to be_exists

    u = User.create! name: 'darkness'
    $user_service_publisher.publish(operate: :update, id: u.id, user: { name: 'light' })
    wait_until(-> { u.reload.name == 'light' })
    expect(u.reload.name).to eq('light')
  end
end
