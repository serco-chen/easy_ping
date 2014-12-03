require 'cgi'

module EasyPing
  module Model

    module List
      attr_reader :has_more, :url

      def get_next_page
        raise ParametersInvalid, 'cannot find the last item of this list' unless models.last
        starting_after = models.last.id
        params = extract_params
        params.delete 'ending_before'
        params.merge!({'starting_after' => starting_after})

        action_class.new(config).all(params)
      end

      def get_next_page!
        setup(get_next_page.response)
      end

      def get_prev_page
        raise ParametersInvalid, 'cannot find the first item of this list' unless models.first
        ending_before = models.first.id
        params = extract_params
        params.delete 'starting_after'
        params.merge!({'ending_before' => ending_before})

        action_class.new(config).all(params)
      end

      def get_prev_page!
        setup(get_prev_page.response)
      end

      alias_method :has_more?, :has_more

    private
      def extract_params
        if params = url.match(/(?:\?).+$/)
          params = url.match(/(?:\?).+$/)[0][1..-1]
          CGI::parse params
        else
          {}
        end
      end
    end

    class Wrapper
      attr_reader :response, :models, :type, :config, :raw, :values

      def initialize(response, config)
        @config = config
        setup(response)
      end

      def setup(response)
        setup_flag = catch(:halt) do
          if response.respond_to?(:body)
            @response = response
            @raw      = response.body
            @values   = JSON.parse(response.body) rescue nil
          elsif response.kind_of?(Hash)
            @response = nil
            @raw      = nil
            @values   = response
          elsif response.kind_of?(String)
            @response = nil
            @raw      = response
            @values   = JSON.parse(response.body) rescue nil
          end
          throw :halt unless @values

          if @values['object'] == 'list'
            @list, @has_more, @url = true, @values['has_more'], @values['url']
            extend List

            @type = /refunds/ =~ @values['url'] ? 'refund' : 'charge'
            @models = @values['data'].map {|object| build_instance(@type, object)}
          elsif ['charge', 'refund'].include? @values['object']
            @type = @values['object']
            @models = build_instance(@type, @values)
          end
          throw :halt unless @models && @type

          # return true if everything went well
          true
        end

        unless setup_flag
          raise EasyPing::ParametersInvalid, "#{values} is not valid charge or refund object."
        end
      end

      def self.parse!(response, config)
        raise EasyPing::APIError.new(response) unless response.success?
        self.new(response, config)
      end

      def build_instance(type, values)
        klass = Model.const_get type.capitalize
        klass.new values
      end

      def list?
        @list ? true : false
      end

      def refund(*args)
        if models.respond_to?(:refund)
          models.refund(config, *args)
        else
          raise NoMethodError, "undefined method `refund' for instance of EasyPing::Model"
        end
      end

      def all_refund(*args)
        if models.respond_to?(:all_refund)
          models.all_refund(config, *args)
        else
          raise NoMethodError, "undefined method `all_refund' for instance of EasyPing::Model"
        end
      end

      extend Forwardable
      # delegators to response
      def_delegators :response, :status, :headers

    private
      def action_class
        type == 'charge' ? EasyPing::Charge : EasyPing::Refund
      end

      def method_missing(name, *args, &block)
        models.send name, *args, &block
      end
    end

    class Abstract
      attr_reader :values

      def initialize(values={})
        @values = values
        @values.each do |key, value|
          self.instance_variable_set("@#{key}".to_sym, value)
        end
      end

      def [](key)
        values[key.to_s]
      end
    end

    class Charge < Abstract
      ATTRIBUTES = [:id, :object, :created, :livemode, :paid, :refunded, :app,
        :channel, :order_no, :client_ip, :amount, :amount_settle, :currency,
        :subject, :body, :extra, :time_expire, :time_settle, :transaction_no,
        :refunds, :amount_refunded, :failure_code, :failure_msg, :metadata,
        :credential, :description
      ]
      attr_reader *ATTRIBUTES
      alias_method :live, :livemode
      alias_method :refunded?, :refunded
      alias_method :order_number, :order_no

      undef :refunds
      def refunds
        refunded? ? @refunds['data'].map {|refund| Refund.new(refund)} : nil
      end

      def live?
        live ? true : false
      end

      def refund(config, *args)
        EasyPing::Refund.new(config).refund(*args, charge_id: id)
      end

      def all_refund(config, *args)
        EasyPing::Refund.new(config).all(id, *args)
      end

      alias_method :all_refunds, :all_refund
      alias_method :get_refund_list, :all_refund
    end

    class Refund < Abstract
      ATTRIBUTES = [:id, :object, :order_no, :amount, :succeed, :created,
        :time_settleme_succeed, :description, :failure_code, :failure_msg, :metadata,
        :charge
      ]
      attr_reader *ATTRIBUTES

      alias_method :charge_id, :charge
      alias_method :succeed?, :succeed
      alias_method :order_number, :order_no
    end

  end
end
