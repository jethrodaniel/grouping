# frozen_string_literal: true

RSpec.describe Grouping do
  it "has a version number" do
    expect(Grouping::VERSION).not_to be_nil
  end

  describe ".group" do
    let(:input_io) do
      StringIO.new(<<~CSV)
        FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
        John,Doe,(555) 123-4567,(555) 987-6543,johnd@home.com,,94105
        Jane,Doe,(555) 123-4567,(555) 654-9873,janed@home.com,johnd@home.com,94105
        Jack,Doe,(444) 123-4567,(555) 654-9873,jackd@home.com,,94109
        John,Doe,(555) 123-4567,(555) 987-6543,jackd@home.com,,94105
        Josh,Doe,(456) 789-0123,,joshd@home.com,jackd@home.com,94109
        Jill,Doe,(654) 987-1234,,jill@home.com,,94129
        ,,,,,,
        ,,,,,,
      CSV
    end
    let(:output_io) { StringIO.new }
    let(:sequence) { described_class::Sequences::IntegerSequence.new }

    context "when strategy is SAME_EMAIL" do
      let(:strategy) { Grouping::Strategies::SAME_EMAIL }

      it "groups by Email1 OR Email2" do
        described_class.group(input_io:, output_io:, strategy:, sequence:)

        expect(output_io.tap(&:rewind).read).to eq(<<~CSV)
          user_id,FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
          1,John,Doe,(555) 123-4567,(555) 987-6543,johnd@home.com,,94105
          1,Jane,Doe,(555) 123-4567,(555) 654-9873,janed@home.com,johnd@home.com,94105
          2,Jack,Doe,(444) 123-4567,(555) 654-9873,jackd@home.com,,94109
          2,John,Doe,(555) 123-4567,(555) 987-6543,jackd@home.com,,94105
          2,Josh,Doe,(456) 789-0123,,joshd@home.com,jackd@home.com,94109
          3,Jill,Doe,(654) 987-1234,,jill@home.com,,94129
          4,,,,,,,
          5,,,,,,,
        CSV
      end
    end

    context "when strategy is SAME_PHONE" do
      let(:strategy) { Grouping::Strategies::SAME_PHONE }

      it "groups by Phone1 OR Phone2" do
        described_class.group(input_io:, output_io:, strategy:, sequence:)

        expect(output_io.tap(&:rewind).read).to eq(<<~CSV)
          user_id,FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
          1,John,Doe,(555) 123-4567,(555) 987-6543,johnd@home.com,,94105
          1,Jane,Doe,(555) 123-4567,(555) 654-9873,janed@home.com,johnd@home.com,94105
          1,Jack,Doe,(444) 123-4567,(555) 654-9873,jackd@home.com,,94109
          1,John,Doe,(555) 123-4567,(555) 987-6543,jackd@home.com,,94105
          2,Josh,Doe,(456) 789-0123,,joshd@home.com,jackd@home.com,94109
          3,Jill,Doe,(654) 987-1234,,jill@home.com,,94129
          4,,,,,,,
          5,,,,,,,
        CSV
      end
    end

    context "when strategy is SAME_EMAIL_OR_PHONE" do
      let(:strategy) { Grouping::Strategies::SAME_EMAIL_OR_PHONE }

      it "groups by Email1 OR Email2 OR Phone1 OR Phone2" do
        described_class.group(input_io:, output_io:, strategy:, sequence:)

        expect(output_io.tap(&:rewind).read).to eq(<<~CSV)
          user_id,FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
          1,John,Doe,(555) 123-4567,(555) 987-6543,johnd@home.com,,94105
          1,Jane,Doe,(555) 123-4567,(555) 654-9873,janed@home.com,johnd@home.com,94105
          1,Jack,Doe,(444) 123-4567,(555) 654-9873,jackd@home.com,,94109
          1,John,Doe,(555) 123-4567,(555) 987-6543,jackd@home.com,,94105
          1,Josh,Doe,(456) 789-0123,,joshd@home.com,jackd@home.com,94109
          2,Jill,Doe,(654) 987-1234,,jill@home.com,,94129
          3,,,,,,,
          4,,,,,,,
        CSV
      end
    end
  end
end
