# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "flint/version"

Gem::Specification.new do |s|
  s.name        = "flint"
  s.version     = Flint::VERSION
  s.authors     = ["vanstee"]
  s.email       = ["vanstee@highgroove.com"]
  s.homepage    = ""
  s.summary     = %q{Flint is a simple Campfire client heavily inspired by the blather gem}
  s.description = %q{Flint is a simple Campfire client heavily inspired by the blather gem}

  s.rubyforge_project = "flint"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "em-http-request"
  s.add_dependency "active_support"
  s.add_dependency "json"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end