# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apiary_blueprint_convertor/version'

Gem::Specification.new do |spec|
  spec.name          = "apiary_blueprint_convertor"
  spec.version       = ApiaryBlueprintConvertor::VERSION
  spec.authors       = ["Zdenek Nemec"]
  spec.email         = ["z@apiary.io"]
  spec.summary       = %q{Apiary Blueprint AST convertor.}
  spec.description   = %q{Convert legacy Apiary Blueprint AST into API Blueprint AST (JSON).}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "minitest"
  
end
