# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'epp-eis/version'

Gem::Specification.new do |s|
  s.name        = 'epp-eis'
  s.version     = Eis::Epp::VERSION
  s.authors     = ['Priit Haamer']
  s.email       = ['priit@fraktal.ee']
  s.homepage    = 'https://github.com/priithaamer/epp-eis'
  s.summary     = %q{Estonian Internet Foundation EPP service client}
  s.description = %q{Ruby client for Estonian Internet Foundation EPP service}

  s.rubyforge_project = 'epp-eis'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'nokogiri'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard'
end
