# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multify/version'

Gem::Specification.new do |gem|
  gem.name          = "multify"
  gem.version       = Multify::VERSION
  gem.authors       = ["Jared Grippe"]
  gem.email         = ["jared@deadlyicon.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rest-client'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'virtus'

  gem.add_development_dependency "debugger"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "nyan-cat-formatter"
end
