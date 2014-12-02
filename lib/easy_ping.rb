require 'json'
require 'faraday'

require 'easy_ping/version'
require 'easy_ping/error'
require 'easy_ping/utils'
require 'easy_ping/config'
require 'easy_ping/model'
require 'easy_ping/action'
require 'easy_ping/base'

module EasyPing

  class << self
    def new(options)
      EasyPing::Base.new(options)
    end

  private
    def method_missing(name, *args, &block)
      default_proxy.send name, *args, &block
    end
  end

  def self.default_proxy
    @default_proxy ||= EasyPing::Base.new
  end

end
