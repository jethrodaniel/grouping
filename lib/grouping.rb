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
    class AnyOfColumns
      def initialize columns
        @columns = columns
      end

      def fetch_or_set_id identifiers, sequence, row
        user_exists = columns.any? { |column| identifiers.key?(row.fetch(column)) }

        id = if user_exists
          column = columns.find { |column| identifiers.key?(row.fetch(column)) }
          field = row.fetch(column)
          identifiers.fetch(field)
        else
          sequence.next
        end

        columns.each do |column|
          field = row.fetch(column)
          identifiers[field] = id unless field.nil?
        end

        id
      end

      private

      attr_reader :columns
    end

    SAME_EMAIL = AnyOfColumns.new(%w[Email1 Email2])
    SAME_PHONE = AnyOfColumns.new(%w[Phone1 Phone2])
    SAME_EMAIL_OR_PHONE = AnyOfColumns.new(%w[Email1 Email2 Phone1 Phone2])
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

      id = strategy.fetch_or_set_id(identifiers, sequence, row)

      output_io.puts CSV.generate_line([id] + row.fields)
    end
  rescue => e
    raise Error, "#{e.class}: #{e.message}"
  end
end
