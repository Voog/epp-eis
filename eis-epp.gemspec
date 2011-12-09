# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'eis-epp/version'

Gem::Specification.new do |s|
  s.name        = 'eis-epp'
  s.version     = Eis::Epp::VERSION
  s.authors     = ['Priit Haamer']
  s.email       = ['priit@fraktal.ee']
  s.homepage    = 'https://github.com/priithaamer/eis-epp'
  s.summary     = %q{Estonian Internet Foundation EPP service client}
  s.description = %q{Ruby client for Estonian Internet Foundation EPP service}

  s.rubyforge_project = 'eis-epp'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'guard'
end
