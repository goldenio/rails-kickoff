# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails/kickoff/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-kickoff'
  spec.version       = Rails::Kickoff::VERSION
  spec.authors       = ['Tse-Ching Ho']
  spec.email         = ['tsechingho@gmail.com']
  spec.summary       = %q{Kick off rails application by rails templates.}
  spec.description   = %q{Kick off rails application by rails templates.}
  spec.homepage      = 'https://github.com/goldenio/rails-kickoff'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
