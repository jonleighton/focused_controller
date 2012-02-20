# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "focused_controller/version"

Gem::Specification.new do |s|
  s.name        = "focused_controller"
  s.version     = FocusedController::VERSION
  s.authors     = ["Jon Leighton"]
  s.email       = ["j@jonathanleighton.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "focused_controller"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'actionpack', '~> 3.2'

  s.add_development_dependency 'minitest', '~> 2.11.2'
  s.add_development_dependency 'capybara', '~> 1.1.2'
  s.add_development_dependency 'capybara_minitest_spec', '~> 0.2.1'
  s.add_development_dependency 'poltergeist', '~> 0.4.0'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'rspec-rails', '~> 2.8.0'
end
