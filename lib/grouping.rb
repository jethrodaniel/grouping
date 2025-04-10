# frozen_string_literal: true

require_relative "grouping/version"

require "csv"

module Grouping
  Error = Class.new(StandardError)

  module Sequences
    class IntegerSequence
      def initialize
        @enum = (1..).to_enum
      end

      def next = @enum.next
    end
  end

  module Strategies
    class SameEmail
      def call identifiers, sequence, row
        field = row["Email1"]

        if identifiers.key? field
          identifiers[field]
        else
          identifiers[field] = sequence.next
        end
      end
    end

    class SamePhone
      def call identifiers, sequence, row
        field = row["Phone1"]

        if identifiers.key? field
          identifiers[field]
        else
          identifiers[field] = sequence.next
        end
      end
    end

    class SameEmailOrPhone
      def call identifiers, sequence, row
        fields = %w[Email1 Phone1]

        id = if fields.any? { |field| identifiers.key?(row[field]) }
          field = fields.find { |field| identifiers.key?(row[field]) }
          identifiers[row[field]]
        else
          sequence.next
        end

        fields.each { |field| identifiers[row[field]] = id }

        id
      end
    end
  end

  USER_ID_COLUMN = :user_id

  def self.group input_io:, output_io:, strategy:, sequence:
    input_enum = CSV.new(input_io, headers: true).each

    identifiers = {}

    input_enum.each_with_index do |row, index|
      if index.zero?
        headers = [USER_ID_COLUMN] + row.headers
        output_io.puts CSV.generate_line(headers)
      end

      id = strategy.call(identifiers, sequence, row)

      output_io.puts CSV.generate_line([id] + row.fields)
    end
  rescue => e
    raise Error, "#{e.class}: #{e.message}"
  end
end
