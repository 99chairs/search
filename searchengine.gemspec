$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "searchengine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "searchengine"
  s.version     = Searchengine::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "https://www.99chairs.com"
  s.summary     = "Whatever makes our system searchable"
  s.description = "Search w/ ES"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"
  s.add_dependency "chewy"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "elasticsearch-extensions"
  s.add_development_dependency "activerecord-tableless"
end
