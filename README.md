# LtsvLogFormatter

A ruby logger formatter to output log in LTSV format

## Installation

Add this line to your application's Gemfile:

    gem 'ltsv_log_formatter'

And then execute:

    $ bundle

## How to use

```ruby
require 'logger'
require 'ltsv_log_formatter'

logger = Logger.new(STDOUT)
logger.formatter = LtsvLogFormatter.new
```

## Rails

Configure at `config/application.rb`

```ruby
config.logger.formatter = LtsvLogFormatter.new
```

## Example

Passing a hash parameter:

```
irb> logger.info({foo: "bar"})
time:20150423T00:00:00+09:00\tlevel:INFO\tfoo:bar
```

Passing a string parameter: `message` key is used as default

```ruby
irb> logger.info("foo")
time:20150423T00:00:00+09:00\tlevel:INFO\tmessage:foo
```

Line feed: Notice that the line feed character `\n` is converted into `\\n`

```ruby
irb> logger.info("foo\nbar")
time:20150423T00:00:00+09:00\tlevel:INFO\tmessage:foo\\nbar
```

## Options

* time_key
  * Change the key name of the time field. Set `nil` to remove. Default: time
* level_key
  * Change the kay name of the level field. Set `nil` to remove. Default: level
* message_key
  * Change the kay name for the string (not hash) message. Default: message

Example)

```ruby
logger.formatter = LtsvLogFormatter.new(time_key: "log_time", level_key: nil)
```

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

See [LICENSE.txt](LICENSE.txt) for details.
