# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'project_releaser/version'

Gem::Specification.new do |spec|
  spec.name          = "project_releaser"
  spec.version       = ProjectReleaser::VERSION
  spec.authors       = ["kagux"]
  spec.email         = ["kaguxmail@gmail.com"]
  spec.description   = 'Manage project release routines'
  spec.summary       = 'Make project release painless'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "git"
  spec.add_runtime_dependency "commander"
  spec.add_runtime_dependency "colorize"
end
