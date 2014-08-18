# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chatwork_to/version'

Gem::Specification.new do |spec|
  spec.name          = "chatwork_to"
  spec.version       = ChatworkTo::VERSION
  spec.authors       = ["nalabjp"]
  spec.email         = ["nalabjp@gmail.com"]
  spec.summary       = %q{Transfer ChatWork messages.}
  spec.description   = %q{ChatWorkTo can transfer ChatWork messages via notifier.}
  spec.homepage      = "https://github.com/nalabjp/chatwork_to"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", '~> 4.1.4'
  spec.add_dependency "mechanize", '~> 2.7.3'
  spec.add_dependency "daemons",  '~> 1.1.9'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-doc"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-rescue"
  spec.add_development_dependency "awesome_print"
end
