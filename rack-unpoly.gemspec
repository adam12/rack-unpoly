require_relative "lib/rack/unpoly/version"

Gem::Specification.new do |spec|
  spec.name = "rack-unpoly"
  spec.version = Rack::Unpoly::VERSION
  spec.authors = ["Adam Daniels"]
  spec.email = "adam@mediadrive.ca"

  spec.summary = "Integrate Unpoly with any Rack or Sinatra application"
  spec.homepage = "https://github.com/adam12/rack-unpoly"
  spec.license = "MIT"

  spec.files = ["README.md", "Rakefile"] + Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.0", "< 4.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "standard", "~> 1.26"
end
