# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitbucket_snagger/version'

Gem::Specification.new do |spec|
  spec.name          = "bitbucket_snagger"
  spec.version       = BitbucketSnagger::VERSION
  spec.authors       = ["Geoff Williams"]
  spec.email         = ["geoff.williams@puppetlabs.com"]

  spec.summary       = %q{Snag public git repos from the internet and upload them to your private bitbucket server}
  spec.homepage      = %q{https://github.com/GeoffWilliams/bitbucket_snagger}
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "escort", "0.4.0"
  spec.add_runtime_dependency "rest-client", "2.0.0"
  spec.add_runtime_dependency 'inifile', '3.0.0'

end
