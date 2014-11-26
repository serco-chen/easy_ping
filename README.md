# EasyPing

EasyPing is an out of the box Ping++ Ruby SDK. Once installed, you're ready to set up a minimal configuration and get started using EasyPing.

**Warn UNDER DEVELOPMENT** Not ready for production purpose yet.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_ping'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_ping

If you prefer to use the latest code, you can build from source:

```
gem build easy_ping.gemspec
gem install easy_ping-<VERSION>.gem
```

## Configuration

Write these lines of code to your configuration file, for example, `easy_ping.rb`.

```ruby
EasyPing.configure do |config|
  config.app_id   = 'app_Wzrrb9DW1GaLmbjn' # required
  config.api_base = 'https://api.pingplusplus.com' # optional, default: https://api.pingplusplus.com
  config.live     = true # optional, default: false
  config.live_key = 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8' # optional unless your are in live_mode
  config.test_key = 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8' # optional unless your are in test_mode
  config.channel = :alipay # optional, default: :alipay, you can modify this option on runtime
  config.currency = :cny # optional, default: :cny
end
```

And put it under `config/initiailizers` directory of your Rails project.

Or require this file manually by yourself.

## Usage

```ruby
## Create Charge ##

charge = EasyPing::Charge.create 100, 'apple', 'one delicous big apple'

# or even simpler
charge = EasyPing.charge 100, 'apple', 'one delicous big apple'

charge = EasyPing.charge 100, 'apple', 'one delicous big apple', {
  time_expire:  '2 days', # or 1410834527 or 2000-01-01 20:15:01 UTC
  metadata:     { color: 'red'},
  description:  'some description for this charge'
}

charge = EasyPing.charge 100, 'apple', 'just an apple' do |charge|
  charge.order_number = Digest::MD5.hexdigest(Time.now.to_s)[0,12]
  charge.channel      = :upmp
end


## Retrieve Single Charge ##

charge = EasyPing::Charge.find 'ch_8OG4WDTe10q1q5G8aL8aDSmH'

# or even simpler
charge = EasyPing.find 'ch_8OG4WDTe10q1q5G8aL8aDSmH'

# string parameters and parameters wrap in a hash are both acceptable
charge = EasyPing.find_charge charge_id: 'ch_8OG4WDTe10q1q5G8aL8aDSmH'

# request again
charge = charge.get


## Retrieve Charge List ##

# start from the beginning and retrieve 10 items
charges = EasyPing.all
charges = EasyPing.get_charge_list
charges = EasyPing::Charge.all

charges = EasyPing.all {
  limit:      10,
  offset:     200, # offset & starting_after, synonym
  paid:       true,
  refunded:   false
}

# using the same options except the offset option
new_charges = charges.get_next_page

# method end with bang will change caller itself
charges.get_prev_page!


## Create Refund ##

EasyPing::Refund.create 50, 'refund description', { charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF' }

# or even simpler
EasyPing.refund 50, 'refund description', { charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF' }

# get charge first and refund from that charge
charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
# refund all the money
charge.refund 'refund description'


## Retrieve Single Refund ##

refund = EasyPing::Refund.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF', 're_TmbvDKHiXLCSG0mnj9jnDyjA'

# or even simpler
refund = EasyPing.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF', 're_TmbvDKHiXLCSG0mnj9jnDyjA'
refund = EasyPing.find_refund charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF', refund_id: 're_TmbvDKHiXLCSG0mnj9jnDyjA'


## Retrieve Refund List ##

refunds = EasyPing::Refund.all(charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF')

# or even simpler
refunds = EasyPing.get_refund_list 'ch_0ijQi5LKqT5sEiOePOKWb1mF'

# get charge first and retrieve its refunds
charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
refunds = charge.get_refund_list {
  limit:      10,
  end_before: 200
}
```

Retrieve charge or refund object from async notification is easy.
EasyPing will automatically detect whether response object is charge
or refund.

```ruby
## Retrieve from Async Notification ##

# charge
charge = EasyPing::Charge.from_notification(response.body)
charge = EasyPing.from_notification(response.body)

# refund
refund = EasyPing::Refund.from_notification(response.body)
refund = EasyPing.from_notification(response.body)
```

See more examples in examples directory.
For Ping++ API information, please visit https://pingplusplus.com/document/api

## Advanced Usage

```ruby
## Runtime Setup ##

# Using different configuration from pre-setup options
ping = EasyPing.new({
  app_id:   'app_Wzrrb9DW1GaLmbjn',
  live:     true,
  live_key: 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8',
  channel:  :wx
})

# do whatever you want without change of default configuration
ping.charge 100, 'apple', 'one delicous big apple'


## Helpers ##

# charge helpers
charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'

charge.live?
charge.amount
charge.refunded?

# refund helpers
refund = EasyPing::Refund.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF', 're_TmbvDKHiXLCSG0mnj9jnDyjA'

refund.full_amount?
refund.succeed?
refund.amount

# config helpers
config = EasyPing.config

config.live?
config.api_key

```

## Error Handling

If fail to create or retrieve charge/refund, an error will be raised.

```ruby
## Error ##

begin
  charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
rescue EasyPing::APIError => e # Error return by server
  puts e.message
  puts e.status # same with e.code
  puts e.type
  puts e.param
rescue EasyPing::Error => e # Top level error of EasyPing
  puts e.message
rescue Exception => boom
  puts "something wrong with your code, #{boom.message}"
  puts boom.backtrace.join("\n")
end
```
