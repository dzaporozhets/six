require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  describe "protection" do 
    let (:rules) { BookRules.new }

    describe "protect!" do 
      before do 
        Six.add_pack(:myrules, rules)
      end

      describe "global rules" do 
        it "should allow acceess" do 
          Six.allowed?(:read_book, 1, 2).should be_true
        end

        it "should prevent unauthorized acceess" do 
          Six.use(:myrules).allowed?(:read_book, 2, 2).should be_false
        end
      end

      describe "namespace rules" do 
        it "should allow acceess" do 
          Six.use(:myrules).allowed?(:read_book, 1, 2).should be_true
        end

        it "should prevent unauthorized acceess" do 
          Six.use(:myrules).allowed?(:read_book, 2, 2).should be_false
        end
      end
    end

    describe "if no rules passed" do 
      it { Six.allowed?(:read_book, 2, 2).should be_false }
    end
  end
end
