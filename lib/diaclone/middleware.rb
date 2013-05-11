# A collection of transformers from `app/transformers`.

module Diaclone
  class Middleware
    attr_reader :transformers, :data

    def initialize with_collection_of_transformers, and_raw_data
      @transformers = with_collection_of_transformers || []
      @data = and_raw_data
    end

    def result
      @result ||= Result.new from_data
    end

    def from_data
      case
      when self.data.is_a?(String)
        { body: self.data }
      when self.data.is_a?(Hash)
        { hash: self.data }
      else
        self.data
      end
    end

    def configured?
      transformers.any?
    end
  end
end
