# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xml_active/version"

Gem::Specification.new do |s|
  s.name        = "xml_active"
  s.version     = XmlActive::VERSION
  s.authors     = ["Michael Harrison"]
  s.email       = ["michael@focalpause.com"]
  s.homepage    = ""
  s.summary     = "xml_active #{s.version}"
  s.description = %q{XML Active is an extension of ActiveRecord that provides features to synchronise an ActiveRecord Model with a supplied XML document}

  s.rubyforge_project = "xml_active"

  s.add_dependency 'nokogiri'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
