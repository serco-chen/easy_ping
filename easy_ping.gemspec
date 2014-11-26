# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_ping/version'

Gem::Specification.new do |spec|
  spec.name          = "easy_ping"
  spec.version       = EasyPing::VERSION
  spec.authors       = ["Cxg"]
  spec.email         = ["xg.chen87@gmail.com"]
  spec.summary       = "Ruby Wrapper for Ping++ API}"
  spec.description   = %q{EasyPing is an out of the box Ping++ Ruby SDK.
                          For Ping++ API information, please
                          visit https://pingplusplus.com for details.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0") - %w[.gitignore]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 0.9.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
