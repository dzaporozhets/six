require_relative 'spec_helper'

describe Six do
  it "should exist" do
    true.must_equal true
  end

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

    describe "two rules that return one permission each" do

      let(:abilities) { Six.new([rule1, rule2]) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:banana]
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

    describe "rejecting permissions" do

      let(:abilities) { Six.new([rule1, rule2]) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
        o.stubs(:prevented).with(subject, nil).returns [:apple]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:apple, :pear]
        o.stubs(:prevented).with(subject, nil).returns [:banana]
        o
      end

      it "should return false for the permissions that are prevented" do
        abilities.allowed?(subject, :banana).must_equal false
        abilities.allowed?(subject, :apple).must_equal false
      end

      it "should return true for the permissions that are not prevented" do
        abilities.allowed?(subject, :pear).must_equal true
        abilities.allowed?(subject, :orange).must_equal true
      end

    end

    describe "alternate constructor" do

      let(:abilities) { Six.new(rule1, rule2) }

      let(:subject) { Object.new }

      let(:rule1) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:orange, :banana]
        o.stubs(:prevented).with(subject, nil).returns [:apple]
        o
      end

      let(:rule2) do
        o = Object.new
        o.stubs(:allowed).with(subject, nil).returns [:apple, :pear]
        o.stubs(:prevented).with(subject, nil).returns [:banana]
        o
      end

      it "should return false for the permissions that are prevented" do
        abilities.allowed?(subject, :banana).must_equal false
        abilities.allowed?(subject, :apple).must_equal false
      end

      it "should return true for the permissions that are not prevented" do
        abilities.allowed?(subject, :pear).must_equal true
        abilities.allowed?(subject, :orange).must_equal true
      end

    end

    describe "no rules provided" do
      it "should return false for everything" do
        abilities = Six.new
        abilities.allowed?(Object.new, :anything).must_equal false
        abilities.allowed?(Object.new, :anything, Object.new).must_equal false
      end
    end

  end

end
