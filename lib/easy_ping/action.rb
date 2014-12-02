require 'json'
module EasyPing
  class Client
    def initialize(api_base, api_key)
      options = {ssl: {ca_file: '../ssl/ca-certificates.crt'}}
      @connection = Faraday.new(api_base, options) do |conn|
        conn.request       :url_encoded
        conn.response      :logger
        conn.authorization :Bearer, api_key
        conn.adapter       Faraday.default_adapter
      end

      def run(method, *args)
        @connection.send method, *args
      rescue Faraday::ClientError => e
        raise EasyPing::HTTPClientError.new(e)
      end
    end
  end

  class Action
    include EasyPing::Utils
    CHANNELS = ["alipay", "wx", "upmp", "alipay_wap", "upmp_wap"]

    attr_reader :client, :config

    def initialize(config)
      @config = config
      @client   = EasyPing::Client.new(config.api_base, config.api_key)
    end

    def from_notification(params)
      EasyPing::Model::Wrapper.new(params, config)
    end

    extend Forwardable
    # delegators to response
    def_delegators :config, :live, :live?, :channel

  private
    def compile(options)
      mappings.each do |*group|
        raise ParametersInvalid, "more than one of #{group} options set" if (options.keys & group).length > 1
      end
      Hash[options.map {|k, v| mappings.key?(k) ? [mappings[k], v] : [k, v] }]
    end

    def verify!(options, requires)
      missing_parameters = requires - options.keys.map(&:to_s)
      if missing_parameters.length > 0
        raise MissingRequiredParameters, %Q{#{missing_parameters} is required
        for this action.}
      end
      if options['channel'] && !CHANNELS.include?(options['channel'].to_s)
        raise ParametersInvalid, %Q{#{options['channel']} is not valid channel
        for this action.}
      end
    end
  end

  class Refund < Action
    def self.create(*args)
      new(EasyPing::Base.config).refund(*args)
    end

    def initialize(config)
      super(config)
      @settings = config.to_options
    end

    def refund(*args)
      amount = args.first
      if Integer === amount
        params = indifferent_params(args, 'amount', 'description', 'charge_id')
      else
        params = indifferent_params(args, 'description', 'charge_id')
      end

      # map keys to API request format and verify options
      params = compile params
      verify! params, refund_requires

      # set up charge id for refund action
      @charge_id = params.delete 'charge_id'

      # run request and parse return result
      raw_response = client.run(:post, api_endpoint, params)
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

    def find(*args)
      params = indifferent_params(args, 'charge_id', 'refund_id')
      @charge_id, @refund_id = params.values_at('charge_id', 'refund_id')

      # run request and parse return result
      raw_response = client.run :get, "#{api_endpoint}/#{@refund_id}"
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

    def all(*args)
      params = indifferent_params(args, 'charge_id')

      # map keys to API request format
      params = compile params

      # set up charge id for refund action
      @charge_id = params.delete 'charge_id'

      raw_response = client.run :get, api_endpoint, params
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

  private
    def api_endpoint
      "/v1/charges/#{@charge_id}/refunds"
    end

    def refund_requires
      ['charge_id', 'description']
    end

    def mappings
      {
        'from'   => 'charge_id',
        'offset' => 'starting_after'
      }
    end
  end

  class Charge < Action
    REQUIRED = [
      'order_no', 'app[id]', 'channel', 'amount', 'client_ip', 'currency',
      'subject', 'body'
    ]

    def self.create(*args)
      new(EasyPing::Base.config).charge(*args)
    end

    def initialize(config)
       super(config)
      @settings = config.to_options.merge default_charge_options
    end

    def charge(*args)
      params = indifferent_params(args, 'order_number', 'amount', 'subject', 'body')
      params = @settings.merge params

      # map keys to API request format and verify params
      params = compile params
      verify! params, charge_requires

      # run request and parse return result
      raw_response = client.run(:post, api_endpoint, params)
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

    def find(*args)
      params = indifferent_params(args, 'charge_id')

      raw_response = client.run :get, "#{api_endpoint}/#{params['charge_id']}"
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

    def all(params={})
      params = indifferent_hash params

      # map keys to API request format
      params = compile params

      raw_response = client.run :get, api_endpoint, params
      EasyPing::Model::Wrapper.parse! raw_response, config
    end

  private
    def api_endpoint
      '/v1/charges'
    end

    def mappings
      {
        'order_number' => 'order_no',
        'app_id'       => 'app[id]',
        'app'          => 'app[id]',
        'offset'       => 'starting_after'
      }
    end

    def default_charge_options
      { 'client_ip' => '127.0.0.1' }
    end

    def charge_requires
      [
        'order_no', 'app[id]', 'channel', 'amount', 'client_ip',
        'currency', 'subject', 'body'
      ]
    end
  end
end
