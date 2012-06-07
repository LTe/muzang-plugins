# -*- encoding: utf-8 -*-
require File.expand_path('../lib/muzang-plugins/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Piotr Niełacny"]
  gem.email         = ["piotr.nielacny@gmail.com"]
  gem.description   = %q{Plugins for Muzang IRC bot}
  gem.summary       = %q{Basic plugins for Muzang IRC bot}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "muzang-plugins"
  gem.require_paths = ["lib"]
  gem.version       = Muzang::Plugins::VERSION

  gem.add_dependency "em-http-request"
  gem.add_dependency "muzang", "~> 1.0.0"
  gem.add_dependency "memetron", "~> 0.1.1"
  gem.add_dependency "soup-client"
  gem.add_dependency "sqlite3"
  gem.add_dependency "activerecord"
  gem.add_dependency "pastie-api"

  gem.add_development_dependency "em-ventually",  "~> 0.1.2"
  gem.add_development_dependency "rspec",         "~> 2.6.0"
  gem.add_development_dependency "rake"
end
