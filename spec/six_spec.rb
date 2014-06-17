require_relative 'spec_helper'

describe Six do
  it "should exist" do
    true.must_equal true
  end

# describe "smoke tests" do
#   it "should work with a constructor argument, too" do
#     expected_results = [:apple]
#     subject          = Object.new
#     target           = Object.new
#     rule_set = Object.new
#     rule_set.stubs(:allowed).with(subject, target).returns expected_results
#     abilities = Six.new([rule_set])
#     abilities.allowed?(subject, :apple, target).must_equal true
#     abilities.allowed?(subject, :orange, target).must_equal false
#   end
# end

  describe "allowed?" do

    describe "there are no rules" do

      let(:abilities) { Six.new }

      it "should return false" do
        abilities.allowed?(nil, :does_not_matter).must_equal false
        abilities.allowed?(Object.new, :something_else).must_equal false
      end

    end

    [:one, :two].each do |permission|

      describe "one rule that returns one permission" do

        let(:abilities) { Six.new([rule]) }

        let(:subject) { Object.new }

        let(:rule) do
          o = Object.new
          o.stubs(:allowed).with(subject, nil).returns [permission]
          o
        end

        it "should return true for the allowed permission" do
          abilities.allowed?(subject, permission).must_equal true
        end

        it "should return false for other permissions" do
          abilities.allowed?(subject, :something_else).must_equal false
          abilities.allowed?(subject, :another_thing).must_equal false
        end

        describe "with a target" do

          let(:target) { Object.new }

          before do
            rule.stubs(:allowed).with(subject, target).returns [permission]
          end

          it "should return true for the allowed permission" do
            abilities.allowed?(subject, permission).must_equal true
          end

          it "should return true if asked for the permission in an array" do
            abilities.allowed?(subject, [permission]).must_equal true
          end

          it "should return false for other permissions" do
            abilities.allowed?(subject, :something).must_equal false
            abilities.allowed?(subject, :another).must_equal false
          end

        end

      end

      describe "one rule that returns two permissions" do

        let(:abilities) { Six.new([rule]) }

        let(:subject) { Object.new }

        let(:rule) do
          o = Object.new
          o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
          o
        end

        it "should return true if asked for either, alone" do
          abilities.allowed?(subject, :orange).must_equal true
          abilities.allowed?(subject, :banana).must_equal true
        end

        it "should return true if asked for both at the same time" do
          abilities.allowed?(subject, [:orange, :banana]).must_equal true
        end

        it "should return true if asked for one and another that does not match" do
          abilities.allowed?(subject, [:orange, :apple]).must_equal false
          abilities.allowed?(subject, [:pear, :banana]).must_equal false
        end

        it "should return false for other permissions" do
          abilities.allowed?(subject, :apple).must_equal false
          abilities.allowed?(subject, :pear).must_equal false
        end

      end

    end

  end

end
