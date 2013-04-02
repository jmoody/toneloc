# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toneloc/version'

Gem::Specification.new do |spec|
  spec.name          = 'toneloc'
  spec.version       = Toneloc::VERSION
  spec.authors       = ['Joshua Moody']
  spec.email         = ['joshuajmoody@gmail.com']
  spec.description   = %q{converts .strings files to and from .csv format}
  spec.summary       = %q{summarized}
  spec.homepage      = 'https://github.com/jmoody/toneloc.git'
  spec.license       = 'THE BEER-WARE LICENSE'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = 'toneloc'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '10.0.3'

  spec.add_runtime_dependency 'fastercsv'
  spec.add_runtime_dependency 'apfel'

end
