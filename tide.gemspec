#-*- encoding: utf-8 -*-
VERSION = "0.5.7"

Gem::Specification.new do |spec|
  spec.name          = "xtide-ruby"
  spec.version       = VERSION
  spec.authors       = ["Forrest Grant"]
  spec.email         = ["forrest@forrestgrant.com"]
  spec.description   = %q{ruby wrapper for xtide}
  spec.summary       = %q{ruby wrapper for xtide}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files = Dir['lib/   *.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_runtime_dependency 'tzinfo'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'geocoder'
end
