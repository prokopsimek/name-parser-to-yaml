# NameParserToYaml

Gem parses names and their name days from server http://behindname.com and saves them formatted into yaml.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'name_parser_to_yaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install name_parser_to_yaml

## Usage

    NameParserToYaml.new('czech').generate!

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prokopsimek/name_parser_to_yaml.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

