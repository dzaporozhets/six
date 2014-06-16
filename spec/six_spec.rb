require_relative 'spec_helper'

describe Six do
  it "should exist" do
    true.must_equal true
  end

  describe "smoke tests" do

    it "should return the results from the rules class" do

      expected_results = [:apple]
      subject          = Object.new
      target           = Object.new

      rule_set = Object.new
      rule_set.stubs(:allowed).with(subject, target).returns expected_results

      abilities = Six.new
      abilities << rule_set

      abilities.allowed?(subject, :apple, target).must_equal true
      abilities.allowed?(subject, :orange, target).must_equal false

    end
  end

end
