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
  config.api_key = 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8' # required
  config.channel = :alipay # optional, default: :alipay, you can modify this option on runtime
end
```

And put it under `config/initiailizers` directory of your Rails project.

Or require this file manually by yourself.

## Usage

```ruby
## Create Charge ##

# Class Method Definitions : Charge Create
EasyPing::Charge.create(order_number, amount, subject, body, options={}) -> charge object
EasyPing::Charge.create(options) -> charge object

# Alias Methods
EasyPing::Charge.create
EasyPing.charge

# Examples
charge = EasyPing::Charge.create 'order_number_1', 100, 'apple', 'one delicous big apple'
charge = EasyPing.charge({
  order_number: 'order_number_2',
  amount:       100,
  subject:      'apple',
  body:         'one delicous big apple',
  app_id:       'app_Wzrrb9DW1GaLmbjn',
  metadata:     { color: 'red'},
})


## Retrieve Single Charge ##

# Class Method Definitions : Charge Find
EasyPing::Charge.find(charge_id) -> charge object
EasyPing::Charge.find(charge_id: charge_id) -> charge object

# Alias Methods
EasyPing::Charge.find
EasyPing.find
EasyPing.find_charge

# Examples
charge = EasyPing::Charge.find 'ch_8OG4WDTe10q1q5G8aL8aDSmH'
charge = EasyPing.find charge_id: 'ch_8OG4WDTe10q1q5G8aL8aDSmH'


## Retrieve Charge List ##

# Class Method Definitions : Charge ALL
EasyPing::Charge.all(options={}) -> charge object list

# Alias Methods
EasyPing::Charge.all
EasyPing.all
EasyPing.all_charges
EasyPing.get_charge_list

# Examples
charges = EasyPing::Charge.all
charges = EasyPing.all {
  limit:      10,
  offset:     'ch_8OG4WDTe10q1q5G8aL8aDSmH', # offset & starting_after, synonym
  paid:       true,
  refunded:   false
}

# Instance Method Definitions : Charge Pagination
charges.get_next_page(options={}) -> charge object list

# Similar Methods
charges.get_next_page
charges.get_next_page! # change charges itself
charges.get_prev_page
charges.get_prev_page! # same above

# Examples
new_charges = charges.get_next_page # note: ending_before option will be omitted
charges.get_prev_page!(limit: 5) # note: starting_after option will be omitted


## Create Refund ##

# Class Method Definitions : Refund Create
EasyPing::Refund.create(description, charge_id) -> refund object
EasyPing::Refund.create(amount, description, charge_id) -> refund object
EasyPing::Refund.create(options) -> refund object

# Alias Methods
EasyPing::Refund.create
EasyPing.refund

# Examples
EasyPing::Refund.create 'refund description', 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
EasyPing.refund({
  amount:      50,
  description: 'refund description',
  charge_id:   'ch_0ijQi5LKqT5sEiOePOKWb1mF'
})

# Instance Method Definitions : Refund Create
charge.refund(amount description) -> refund object
charge.refund(description) -> refund object
charge.refund(options) -> refund object

# Examples
charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
refund = charge.refund 10, 'refund description'


## Retrieve Single Refund ##

# Class Method Definitions : Refund Find
EasyPing::Refund.find(charge_id, refund_id) -> refund object
EasyPing::Refund.find(options) -> refund object

# Alias Methods
EasyPing::Refund.find
EasyPing.find
EasyPing.find_refund

# Special Note:
#   Must provide both charge_id and refund_id,
#   if only charge_id provided, it will retrieve a charge object

# Examples
refund = EasyPing::Refund.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF', 're_TmbvDKHiXLCSG0mnj9jnDyjA'
refund = EasyPing.find_refund charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF', refund_id: 're_TmbvDKHiXLCSG0mnj9jnDyjA'


## Retrieve Refund List ##

# Class Method Definitions : Refund All
EasyPing::Refund.all(charge_id, options={}) -> refund object list
EasyPing::Refund.all(options) -> refund object list

# Alias Methods
EasyPing::Refund.all
EasyPing.all_refund
EasyPing.all_refunds # in case of plural format typo
EasyPing.get_refund_list

# Examples
refund_list = EasyPing::Refund.all 'ch_0ijQi5LKqT5sEiOePOKWb1mF', { limit: 5 }
refund_list = EasyPing.all_refund charge_id: 'ch_0ijQi5LKqT5sEiOePOKWb1mF'

# Instance Method Definitions : Refund All
charge.all_refund(options={}) -> refund object list

# Alias Methods
charge.all_refund
charge.all_refunds # in case of typo
charge.get_refund_list

# Examples
charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
refund_list = charge.all_refund limit: 5
```

Retrieve charge or refund object from async notification is easy.
EasyPing will automatically detect whether response object is charge
or refund.

```ruby
## Retrieve from Async Notification ##

# Class Method Definitions : Async Notification
EasyPing.from_notification(params) -> charge/refund object

# Alias Methods
EasyPing::Charge.from_notification(params)
EasyPing::Refund.from_notification(params)

# Special Note:
#   1. params can a JSON string or a decoded hash object
#   2. it will automatically detect charge/refund object
#      no matter which method you call

# Examples
charge = EasyPing::Charge.from_notification(params)
refund = EasyPing::Refund.from_notification(params)
```

## Advanced Usage

```ruby
## Runtime Setup ##

# Using different configuration from pre-setup options
ping = EasyPing.new({
  app_id:   'app_Wzrrb9DW1GaLmbjn',
  api_key: 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8',
  channel:  :wx
})

# do whatever you want without change of default configuration
ping.charge 'order_number_3' 100, 'apple', 'one delicous big apple'

## Helpers ##

# instance helpers
charge.raw # raw response body, typically json string
charge.values # response body, hash
charge.heasers # response headers
charge.status # response status, http code
charge.live? # livemode or not

# all attributes
charge.amount
charge.livemode
charge.refunded

# note: refund objects apply same rules above

## Config ##
config = EasyPing.config

config.api_key
config.app_id
config.to_options # return config in hash format

EasyPing.config # return default config

ping = EasyPing.new({
  app_id:   'app_Wzrrb9DW1GaLmbjn',
  api_key: 'sk_test_Dq54mDyHufz9nrPeH8Hm50G8',
})
ping.config # return config for this ping instance

## Available Channels ##
["alipay", "wx", "upmp", "alipay_wap", "upmp_wap"]
```

## Error Handling

If fail to create or retrieve charge/refund, an error will be raised.

```ruby
## Error ##

begin
  charge = EasyPing::Charge.find 'ch_0ijQi5LKqT5sEiOePOKWb1mF'
rescue EasyPing::APIError => e # Error return by server
  puts e.message
  puts e.status
  puts e.type
  puts e.param
rescue EasyPing::Error => e # Top level error of EasyPing
  puts e.message
rescue Exception => boom
  puts "something wrong with your code, #{boom.message}"
  puts boom.backtrace.join("\n")
end
```

## Others

For Ping++ API information, please visit https://pingplusplus.com/document/api

If something doesn't work, feel free to report a bug or start an issue.
