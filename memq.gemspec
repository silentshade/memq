# -*- encoding: utf-8 -*-
require File.expand_path('../lib/memq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SilentShade"]
  gem.email         = ["lifeemulation@gmail.com"]
  gem.description   = %q{Simple and lightweight memcached based queue solution}
  gem.summary       = %q{This gem is a port from PHP MEMQ class}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "memq"
  gem.require_paths = ["lib"]
  gem.version       = Memq::VERSION

  gem.add_dependency "dalli"
  gem.add_development_dependency "rspec"
  
end
