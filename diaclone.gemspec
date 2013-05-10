$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "diaclone/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "diaclone"
  s.version     = Diaclone::VERSION
  s.authors     = ["Tom Scott", "Rob Di Marco", "Chris MacNaughton"]
  s.email       = ["tom.scott@elocal.com", "rob@elocal.com", "chris@elocal.com"]
  s.homepage    = "http://elocal.github.io/diaclone"
  s.summary     = "A micro-parsing library for Rails apps, inspired by Rack."
  s.description = "A micro-parsing library for Rails apps, inspired by Rack."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "rspec"
end
