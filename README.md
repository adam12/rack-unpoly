# Unpoly for Rack & Sinatra

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rack-unpoly"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-unpoly

## Usage in a Rails application

Use the official [Unpoly](https://rubygems.org/gems/unpoly-rails) gem from Makandra.

## Usage in a Sinatra application

```ruby
require "sinatra/base"
require "sinatra/unpoly"

class App < Sinatra::Base
  register Sinatra::Unpoly

  get "/" do
    if up?
      "Unpoly request!"
    else
      "Not Unpoly :("
    end
  end
end
```

## Usage in a Roda application

Use the [roda-unpoly](https://rubygems.org/gems/roda-unpoly) gem.

## Usage in a Rack application (that's not Rails, Sinatra, or Roda)

```ruby
require "rack"
require "rack/unpoly/middleware"

use Rack::Unpoly::Middleware

app = ->(env) {
  if env["rack.unpoly"].up?
    [200, {}, ["Unpoly request!"]]
  else
    [200, {}, ["Not Unpoly :("]]
  end
}

run app
```

## Where are the Javascript and CSS assets?

I've chosen not to bundle those assets with the gem as they might be updated more
frequently then this library. Most Ruby web libraries outside of Rails are asset-agnostic
(for the most part), so it's easier if you bring in your assets as you see fit for your
specific needs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/adam12/rack-unpoly.

I love pull requests! If you fork this project and modify it, please ping me to see
if your changes can be incorporated back into this project.

That said, if your feature idea is nontrivial, you should probably open an issue to
[discuss it](http://www.igvita.com/2011/12/19/dont-push-your-pull-requests/)
before attempting a pull request.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
