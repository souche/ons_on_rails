[![GitHub issues](https://img.shields.io/github/issues/souche/ons_on_rails.svg)](https://github.com/souche/ons_on_rails/issues)
[![GitHub forks](https://img.shields.io/github/forks/souche/ons_on_rails.svg)](https://github.com/souche/ons_on_rails/network)
[![GitHub stars](https://img.shields.io/github/stars/souche/ons_on_rails.svg)](https://github.com/souche/ons_on_rails/stargazers)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/souche/ons_on_rails/master)
[![Gem Version](http://img.shields.io/gem/v/ons_on_rails.svg)](https://rubygems.org/gems/ons_on_rails)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://souche.mit-license.org/)


# OnsOnRails

整合阿里云 ONS 到 Rails 项目

## 项目依赖

* Linux/Unix 系统
* Ruby 2.1.5 或以上版本
* Rails 4.1.0 或以上版本

## 如何使用

### 配置 Rails 环境

#### 在 Gemfile 添加依赖规则

```ruby
gem 'ons', group: :linux
gem 'ons_on_rails'
```

#### 在 config/application.rb 添加 require 规则

```ruby
Bundler.require(*Rails.groups)
Bundler.require(RUBY_PLATFORM.match(/(linux|darwin)/)[0].to_sym)
```

#### 在 config/ 目录下添加配置文件 ons\_on\_rails.yml

```yaml
#
# access_key，阿里云官网身份验证访问码
# secret_key，阿里云身份验证密钥
#
# user_service_subscriber，消费者名称，需要与实际定义的类名信息保持一致，具体见下文的消费者章节
# user_service_subscriber#consumer_id，阿里云 MQ 控制台创建的 Consumer ID
# user_service_subscriber#topic，阿里云 MQ 控制台创建的 Topic
# user_service_subscriber#tag，当前消费者订阅的 Topic 下所关注的消息标签表达式
#
# user_service_publisher，生成者名称，具体见下文的生成者章节
# user_service_publisher#producer_id，阿里云 MQ 控制台创建的 Producer ID
# user_service_publisher#topic，阿里云 MQ 控制台创建的 Topic
# user_service_publisher#tag，当前生成者发布的消息所使用的消息标签
#
default: &default
  access_key: <%= ENV['ONS_ACCESS_KEY'] %>
  secret_key: <%= ENV['ONS_SECRET_KEY'] %>
  user_service_subscriber:
    consumer_id: <%= ENV['ONS_CONSUMER_ID'] %>
    topic: <%= ENV['ONS_TOPIC'] %>
    tag: 'user_service'
  user_service_publisher:
    producer_id: <%= ENV['ONS_PRODUCER_ID'] %>
    topic: <%= ENV['ONS_TOPIC'] %>
    tag: 'user_service'

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
```

### 消费者

#### 在 app/subscribers 目录下添加消费者实现文件，比如 user\_service\_subscriber.rb

```ruby
# 注意，类名应当与 config/ons_on_rails.yml 中的配置保持一致
class UserServiceSubscriber
  include OnsOnRails::Subscriber

  def consume(message)
    # do something...
  end
end
```

#### 在 daemons/ 目录下添加守护进程定义文件，比如 user\_service\_subscriber\_control.rb

```ruby
require 'rubygems'
require 'ons_on_rails'

APP_PATH = File.expand_path('../..', __FILE__)
OnsOnRails.run_subscriber_as_a_daemon(:user_service_subscriber, APP_PATH)
```

#### 启动或关闭消费者进程，此进程会与阿里云 MQ 建立 TCP 连接，然后在本地消费消息

```bash
$ RAILS_ENV=development bundle exec ruby daemons/user_service_subscriber_control.rb start
$ RAILS_ENV=development bundle exec ruby daemons/user_service_subscriber_control.rb stop
```

### 生产者

#### 在 config/initializers/ 目录下添加初始化文件，比如 ons\_on\_rails.rb

```ruby
# 注意，第一个参数应当与 config/ons_on_rails.yml 中的配置保持一致
$user_service_publisher = OnsOnRails.create_publisher(:user_service_publisher, backend: :tcp)
```

#### 调用 OnsOnRails::Publisher#publish 方法

```ruby
$user_service_publisher.publish(operate: :create, user: { name: '123456lkjhgf' })
```

#### 测试相关

设置 OnsOnRails::Publisher 的 backend 为 :test 方法即可，这样生产者会将消息保存到 OnsOnRails::Publisher.deliveries 数组中
