module EasyPing
  class Config
    OPTIONS = [:app_id, :channel, :currency]
    attr_accessor *OPTIONS
    attr_accessor :api_base, :api_key

    def initialize(options)
      options.each do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end

    def api_key
      @api_key or raise EasyPing::MissingKeyError.new, "Missing API key"
    end

    def to_options
      options = {}
      values = OPTIONS.map { |key| self.send key }
      OPTIONS.zip(values) { |k,v| options[k.to_s] = v }
      options
    end
  end
end
