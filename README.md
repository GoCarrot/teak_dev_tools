# Teak Devevelopment Tools

This gem simplifies development and debugging tasks for the Teak SDKs
 * [Android](https://github.com/gocarrot/teak-android)
 * [iOS](https://github.com/gocarrot/teak-ios)
 * [Adobe Air](https://github.com/gocarrot/teak-air)
 * [Unity](https://github.com/gocarrot/teak-unity)

We use this gem internally for development, as well as automated testing.

## Note

This tool currently only works with the development versions of the Teak SDK.

The first SDK version that will be compatible with these tools is the 0.12.x family.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'teak_dev_tools'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teak_dev_tools

## Usage

The easiest way to use the tools is to pipe a device log into 

For Android

    $ adb logcat -s *:D | teak-log

For iOS

    $ idevicesyslog | teak-log

You can also just feed a logfile to the tool as well

    $ teak-log mydevice.log

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GoCarrot/teak_dev_tools.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
