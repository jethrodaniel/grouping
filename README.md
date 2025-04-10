# Grouping

A Ruby gem to process a CSV file and identify unique users based on various matching rules.

It streams an input CSV file and outputs a CSV file where each row is prepended with a new `user_id` column that uniquely identifies that user.

## Installation

To install the CLI tool globally:

```shell
git clone https://github.com/jethrodaniel/grouping
cd grouping
bundle
bundle exec rake install
```

Or, to use in an existing project, add to your `Gemfile`:

```ruby
gem "grouping", github: "jethrodaniel/grouping"
```

Then run `bundle install`.

## Usage

### CLI

There's a basic [CLI](exe/grouping) program included:

```
$ bundle exec grouping

Usage: grouping [...COLUMNS]

Read a CSV from stdin, and output a CSV with `user_id`s to stdout.

Columns that don't exist in the input are ignored.

Examples:

  grouping Email Email1 < input.csv > output.csv
  grouping Zip < input.csv | sort -n
```

### Library

Use in an existing Ruby project like so:

```ruby
require "grouping"

# Input and output IO streams
#
input_io = File.open('input.csv', 'r')
output_io = File.open('output.csv', 'w')

# This is the only supported option currently, but you can use anything that
# generates unique sequence values when `.next` is called.
#
# For example:
#
# ```
# require "securerandom"
#
# class UuidSequence
#   def next = SecureRandom.uuid
# end
#
# uuid_sequence = UuidSequence.new
# ```
#
sequence = Grouping::Sequences::IntegerSequence.new

# Pick a matching type - we currently support:
#
# - Grouping::Strategies::SAME_EMAIL (any of Email, Email1, or Email2)
# - Grouping::Strategies::SAME_PHONE (any of Phone, Phone1, or Phone2)
# - Grouping::Strategies::SAME_EMAIL_OR_PHONE (any of SAME_EMAIL or SAME_PHONE)
#
# Or create your own:
#
strategy = Grouping::Strategies::AnyOfColumns.new(["Zip", "FirstName"])

# Stream the input IO and write to the output IO
#
Grouping.group(input_io:, output_io:, matcher:, sequence:)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Also, `rake` is setup to lint and test your code.

## Contributing

You don't, this is not open-source.
