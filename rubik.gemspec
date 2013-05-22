# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/version'

Gem::Specification.new do |gem|
  gem.name          = "rubik"
  gem.version       = Rubik::VERSION
  gem.authors       = ["Baris Gumustas"]
  gem.email         = ["barisgumustas@gmail.com"]
  gem.description   = "Rubik is a gem to track realtime quantitive metrics such as the average duration of a method execution."
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/matrushka/rubik"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "redis"
  gem.add_dependency "sinatra"
  gem.add_dependency "rake"
  gem.add_dependency "activesupport"
  gem.add_dependency "mustache"
  gem.add_dependency "i18n"
  gem.add_dependency 'multi_json', '~> 1.0'

  gem.add_development_dependency "oj"
  gem.add_development_dependency "awesome_print"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "cane"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "slim"
  # gem.add_development_dependency "rb-inotify"
  gem.add_development_dependency "rb-fsevent"
  # gem.add_development_dependency "rb-fchange"
  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "guard-cane"
  gem.add_development_dependency "puma"
end

