# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "focused_controller/version"

Gem::Specification.new do |s|
  s.name        = "focused_controller"
  s.version     = FocusedController::VERSION
  s.authors     = ["Jon Leighton"]
  s.email       = ["j@jonathanleighton.com"]
  s.homepage    = "http://github.com/jonleighton/focused_controller"
  s.summary     = %q{Write Rails controllers with one class per action}
  s.description = %q{Write Rails controllers with one class per action}

  s.rubyforge_project = "focused_controller"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'actionpack', '>= 3.0', '<= 4.1'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'capybara',               '~> 2.1'
  s.add_development_dependency 'capybara_minitest_spec', '~> 1.0'
  s.add_development_dependency 'poltergeist',            '~> 1.3'
  s.add_development_dependency 'rspec',                  '~> 2.8'
  s.add_development_dependency 'rspec-rails',            '~> 2.8'
  s.add_development_dependency 'appraisal',              '~> 1.0'
end
