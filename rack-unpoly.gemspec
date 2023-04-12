Gem::Specification.new do |spec|
  spec.name = "rack-unpoly"
  spec.version = "0.4.0"
  spec.authors = ["Adam Daniels"]
  spec.email = "adam@mediadrive.ca"

  spec.summary = %q(Integrate Unpoly with any Rack or Sinatra application)
  spec.homepage = "https://github.com/adam12/rack-unpoly"
  spec.license = "MIT"

  spec.files = ["README.md", "Rakefile"] + Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.0", "< 3.0"
  spec.add_dependency "hashie", ">= 3.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rubygems-tasks", "~> 0.2"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "sinatra", ">= 2.0"
end
