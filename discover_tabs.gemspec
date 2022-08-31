# encoding: utf-8
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'discover_tabs'
  gem.version = DiscoverTabs::VERSION
  gem.date    = Date.today.to_s
  gem.license = 'MIT'
  gem.executables = [ "discover_tabs" ]

  gem.summary = "Discover which files are tab indented"
  gem.description = "Library and Command line for discovering files that contain tab indentation"

  gem.authors  = ['Bas Vodde']
  gem.email    = 'basv@odd-e.com'
  gem.homepage = 'https://github.com/basvodde/discover_tabs'

  gem.add_runtime_dependency( 'rake', '~> 12.3.3')
  gem.add_runtime_dependency( 'ptools', '~> 1.1')
  gem.add_development_dependency('rspec', '~> 2.0', '>= 2.0.0')

  gem.files = `git ls-files -- {.,test,spec,lib,bin}/*`.split("\n")
end
