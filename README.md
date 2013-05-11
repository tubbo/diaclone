# Diaclone

A Rack-inspired library for parsing text into a Hash of values. You can
generate "transformers" and run a set of text through all of them. They
in turn use very small bits of logic in separate "cell" classes, which
create objects that do one thing and one thing well. These objects are
easily testable, and help to refactor long tracts of imperative code,
which are difficult to debug and test.

It is currently in production use by [eLocal](http://elocal.com) for
the email parser component of our lead marketplace API.

## Etymology

Diaclone is the [original branding](http://en.wikipedia.org/wiki/Diaclone)
of Hasbro's [Transformers](http://en.wikipedia.org/wiki/Transformers)
franchise.

## Installation

In your Gemfile:

```ruby
gem 'diaclone'
```

Bundle, and run this on the command line to set up your configuration:

```bash
$ rails generate diaclone:install
```

## Usage

Generally, transformers are just an object that responds to the method
`parse(result)`, and returns the same `Diaclone::Result` object that was
passed in. That being said, we've included a number of generators you
can use to develop transformers in a conventionally-acceptable way, that
has been "battle-tested" by us at eLocal to be the most clear way of
expressing these classes.

### The Basics

Here's how you generate a basic transformer:

```bash
$ rails generate transformer contact_info_split
```

It will make the following beautiful class in
**app/transformers/contact_info_split_transformer.rb**...

```ruby
require 'diaclone'

class ContactInfoSplitTransformer
  def self.parse result
    # do your parsing here
    result # but don't forget this line to return the result!
  end
end
```

...as well as a test file in **test/unit/transformers/contact_info_split_transformer_test.rb**,
or spec file in **spec/transformers/contact_info_split_transformer_spec.rb** if
you're using RSpec. The following example is in RSpec:

```ruby
require 'spec_helper'
require_relative '../../app/transformers/contact_info_split_transformer'

describe ContactInfoSplitTransformer do
  let(:result) { Diaclone::Result.new "test data" }
  subject { SplitTransformer.parse result }
  it "parses text" do
  end
end
```

There are a few other generators you can use to alter the way the
implementation class looks. In this most basic example, we generated a
class without state that just passes in a result and returns the same
object, but slightly mutated. You can also generate an object that has
state, and must be instantiated with some given configuration, if you
use the following command:

```bash
$ rails generate transformer:stateful split
```

This generates a class which has state, and must be instantiated. It's
useful for providing a bit of configuration into your class, so you can
write more generic and reusable objects.

Here's what a class generated like this *could* look like...

```ruby
require 'diaclone'

class SplitTransformer
  attr_reader :options

  def initialize with_options={}
    @options = with_options
  end

  def parse result
    result.lines = "#{result}".split options[:delimiter]
    result # but don't forget this line to return the result!
  end
end
```

This class can be called in your test like so:

```ruby
require 'spec_helper'
require_relative '../../app/transformers/split_transformer'

describe SplitTransformer do
  subject { SplitTransformer.new delimiter: "\n" }
  let(:fixture_data) { { body: "test\ndata" } }
  let(:result) { subject.parse Diaclone::Result.new(fixture_data) }

  it "uses the newline character as a delimiter" do
    expect(subject.delimiter).to eq("\n")
  end

  it "loads the correct fixture data" do
    expect(subject.body).to eq("test\ndata")
  end

  it "splits on newlines" do
    expect(result.lines).to_not be_empty
  end

  it "finds the correct amount of newlines" do
    expect(result.lines.count).to eq(2)
  end
end
```

As you can see, it's very easy to set up test cases and work out
problems in your parsing logic, even remove whole sections entirely,
while retaining a level of assurance that your application will continue
to parse things even in high-performance production scenarios.

## Contributing

Anyone can contribute to this project with a Git or GitHub **pull
request**. Please enclose tests with your fixes or features or they will
not be accepted.

### Yell at these guys if this shit breaks

- [Tom Scott](http://psychedeli.ca)
- [Rob Di Marco](http://innovationontherun.com/)
- [Chris MacNaughton](http://chrismacnaughton.com/)
