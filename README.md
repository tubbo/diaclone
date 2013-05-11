# Diaclone

A Rack-inspired library for parsing text into a Hash of values. You can
generate "transformers" and run a set of text through all of them. They
in turn use very small bits of logic in separate "cell" classes, which
create objects that do one thing and one thing well. These objects are
easily testable, and help to refactor long tracts of imperative code,
which are notoriously difficult to debug and test.

It is currently in production use by [eLocal](http://elocal.com) for
the email parser component of our lead marketplace API.

### Etymology

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

## What are Transformers?

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
  let(:result) { Diaclone::Result.new(body: "test data") }
  subject { ContactInfoSplitTransformer.parse result }
  it "parses text" do
  end
end
```

### Advanced

Typically, you will want to alter some kind of configuration for each
class in order to reduce some duplication for very similar requirements.
For example, it may be better to build and test a `SplitTransformer`
that can be configured to split a given body text on any delimiter,
rather than a `ContactInfoSplitTransformer`, which very specifically
matches on a given regex of delimiters that are pre-set into the code.

The transformer we just described above can be modified to support
splitting a given body text on newlines, or `\n`:

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

This class is now stateful, and requires some sort of instantiation for
use. In your middleware array, call the class like so:

```ruby
config.parsing.middleware = [
  SplitTransformer.new(delimiter: "\n")
]
```

You can also test the way that this class transforms a `Result` object
into a workable piece of data. Here is a test that could be written for
this particular class, based off of code that we actually use at
**eLocal**:

```ruby
require 'spec_helper'
require_relative '../../app/transformers/split_transformer'

describe SplitTransformer do
  subject { SplitTransformer.new delimiter: "\n" }
  let(:fixture_data) { { body: "test\ndata" } }
  let(:result) { subject.parse Diaclone::Result.new(fixture_data) }

  it "uses the newline character as a delimiter" do
    expect(subject.options).to have_key(:delimiter)
    expect(subject.options[:delimiter]).to eq("\n")
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

## Using Diaclone

Diaclone is a generic parser framework that can realistically be used in
any Ruby application. Although we provide Rails generators, and have
intended this for use in a Rails app, Diaclone can be used to parse
anything, especially large bodies of text that need transformation or
data cleanup.

### The Middleware object

`Diaclone::Middleware` can be used as a minimal "wrapper" that takes
a collection of transformers and runs raw data through them as a
`Diaclone::Result`:

```ruby
middleware = [
  SplitTransformer.new(delimiter: "\n")
]
raw_data = { body: "test data" }
result = Diaclone::Middleware.new(middleware, raw_data).result
```

This minimal wrapper completes the picture and allows you to simply pass
in data to an array of configured middleware, and it returns a
`Diaclone::Result` object for you to use.

### Configuration in a Rails app

The generator `diaclone:install` should have created an initializer
called **config/initializers/diaclone.rb** which describe your
application's parsing configuration. All configuration for parsing logic
is held in the `config.parsing` namespace of your Rails application
config. We have one available that is somewhat "reserved", called
`config.parsing.middleware`, that is used to hold an
`ActiveSupport::HashWithIndifferentAccess` filled with keyed arrays of
all the middleware used for different purposes. You can use the keys of
the hash to describe the purpose of each middleware stack, like so:

```ruby
Rails.application.config.parsing.middleware.merge(
  "affiliate-slug" => [
    SplitTransformer.new(delimiter: "\n")
  ]
)
```

You can then use this anywhere by just instantiating a Middleware
object:

```ruby
middleware = Rails.application.config.parsing.middleware
data = { body: "test data" }
result = Diaclone::Middleware.new(middleware, data).result
```

## Contributing

Anyone can contribute to this project with a Git or GitHub **pull
request**. Please enclose tests with your fixes or features or they will
not be accepted.

### Yell at these guys if this shit breaks

- [Tom Scott](http://psychedeli.ca)
- [Rob Di Marco](http://innovationontherun.com/)
- [Chris MacNaughton](http://chrismacnaughton.com/)
