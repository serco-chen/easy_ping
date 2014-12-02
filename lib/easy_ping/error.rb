module EasyPing
  class Error < StandardError
    def inspect
      %(#<#{self.class}>)
    end
  end

  # Wrap Faraday client error
  class HTTPClientError < Error
    def initialize(exception)
      @exception = exception
      super(exception.message)
    end

    def backtrace
      if @exception
        @exception.backtrace
      else
        super
      end
    end
  end

  # Wrap error responded from server side
  class APIError < Error
    attr_reader :status, :type, :code, :param
    def initialize(response)
      @status  = response.status
      @error   = JSON.parse(response.body)['error'] rescue {}
      @type    = @error['type']
      @code    = @error['code']
      @param   = @error['param']
      @message = @error['message']

      message =  "Server responded with status #{@status}."
      message += " Full Message: #{@message}." if @message
      super(message)
    end
  end

  class SDKError < Error; end

  class MissingKeyError < SDKError; end
  class MissingRequiredParameters < SDKError; end
  class ParametersInvalid < SDKError; end
  class ArgumentInvalid < SDKError; end


  [:APIError, :SDKError, :MissingKeyError, :MissingRequiredParameters,
   :ParametersInvalid, :ArgumentInvalid].each do |const|
    Error.const_set(const, EasyPing.const_get(const))
  end
end
