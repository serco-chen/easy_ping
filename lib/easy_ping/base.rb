module EasyPing
  class Base
    include EasyPing::Utils
    attr_reader :config
    DEFAULTS = {
      'api_base' => 'https://api.pingplusplus.com',
      'currency' => 'cny'
    }

    def initialize(options={})
      @config = EasyPing::Config.new(
        DEFAULTS.merge indifferent_hash(options)
      )
    end

    def configure
      yield config
    end

    def settings
      config.to_options
    end

    def charge_instance
      EasyPing::Charge.new(config)
    end

    def refund_instance
      EasyPing::Refund.new(config)
    end

    def find(*args)
      params = indifferent_params(args, 'charge_id', 'refund_id')
      if params['charge_id'] && params['refund_id']
        refund_instance.find(params)
      elsif params['charge_id']
        charge_instance.find(params)
      else
        raise ArgumentInvalid, "missing charge_id"
      end
    end

    def from_notification(params)
      EasyPing::Action.new(config).from_notification(params)
    end

    alias_method :get,         :find
    alias_method :find_charge, :find
    alias_method :find_refund, :find

    extend Forwardable
    # delegators to charge
    def_delegators :charge_instance, :charge, :all, :find_list
    # delegators to refund
    def_delegators :refund_instance, :refund

    # delegators alias
    def_delegator  :charge_instance, :all, :get_charge_list
    def_delegator  :charge_instance, :all, :all_charges
    def_delegator  :refund_instance, :all, :get_refund_list
    def_delegator  :refund_instance, :all, :all_refund
    # in case some use refunds as plural form
    def_delegator  :refund_instance, :all, :all_refunds
  end
end
