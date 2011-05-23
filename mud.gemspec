# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mud/version"

Gem::Specification.new do |s|
  s.name        = "mud"
  s.version     = Mud::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mirza Kapetanovic", "Mathias Buus"]
  #s.email       = [""]
  s.homepage    = "http://mudhub.org"
  s.summary     = %q{Simple browser Javascript package manager}
  s.description = %q{Mud is a simple package manager for client-side Javascript. Used for installing new packages and resolving dependencies.}

  s.rubyforge_project = "mud"

  s.add_dependency("sinatra", ">= 1.1.2")
  s.add_dependency("thor", ">= 0.14.6")
  s.add_dependency("hpricot", ">= 0.8.4")

  s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["mud"]
  s.require_paths = ["lib"]
end
