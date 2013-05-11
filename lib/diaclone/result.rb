# Parse result that's passed around in the stack and eventually returned
# at the end of parsing. Includes a `lines` array for holding each line
# of the message, a `body` string for holding the entire raw message
# data, and a `hash` that is eventually read into the `ActiveRecord` object 
# for storage in the database and dissemination to eLocal.com.
#
# A result must start with a body, but this can be an empty string so
# long as the other ^fields are filled out. These fields, like `lines`
# and `hash`, can be populated here as well, so one can "preload"
# the result with test data or begin at a specific point in the stack.
#
# Example:
#
#     Diaclone::Result.new "Message: body."
#     Diaclone::Result.new "", hash: { message: "body." }

module Diaclone
  class Result
    attr_accessor :body, :lines, :hash

    def initialize with_options={}
      @body, @lines, @hash, @extras = "", [], {}, nil

      with_options.each do |property, value|
        self.send :"#{property}=", value
      end
    end

    # Make an exact duplicate of this Result, allowing experimentation
    # or modulation without touching the original object (or perhaps
    # creating an entirely new object to pass around).
    def dup
      pr = Result.new(body)
      pr.lines   = lines.nil?   ? nil : lines.dup
      pr.hash    = hash.nil?    ? nil : hash.dup
      pr.extras  = extras.nil?  ? nil : extras.dup
      pr
    end

    # Access the Hash if a symbol is passed in as the key, otherwise
    # access the `lines` array.
    def [] key
      if key.is_a? Symbol
        self.hash[key]
      else
        self.lines[key]
      end
    end

    # Mutate the Hash if a symbol is passed in as the key, otherwise
    # mutate the `lines` array.
    def []= key, value
      self.hash[key] = value
    end

    # Print the parsed Hash as a String.
    def to_s
      self.hash.reduce("") { |a,(k,v)| a << "#{k}: #{v}" }
    end

    # Print the raw body as a String.
    def raw
      self.body
    end

    # Delete a key from the Hash.
    def delete key
      self.hash.delete key
    end

    # An Array of all attributes in the Hash.
    def keys
      self.hash.keys
    end
  end
end
