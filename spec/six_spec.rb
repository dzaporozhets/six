require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  describe "protection" do 
    class BookRules
      def allowed(object, subject)
        rules = []
        rules << :read_book if object == 1 && subject == 2
        rules
      end
    end

    describe "protect!" do 
      before do 
        @rules = BookRules.new
        @guard = Six::Guard.instance
        @guard.add_pack(:myrules, @rules)
      end

      describe "global rules" do 
        it "should allow acceess" do 
          @guard.allowed?(:read_book, 1, 2).should be_true
        end

        it "should prevent unauthorized acceess" do 
          @guard.use(:myrules).allowed?(:read_book, 2, 2).should be_false
        end
      end

      describe "namespace rules" do 
        it "should allow acceess" do 
          @guard.use(:myrules).allowed?(:read_book, 1, 2).should be_true
        end

        it "should prevent unauthorized acceess" do 
          @guard.use(:myrules).allowed?(:read_book, 2, 2).should be_false
        end
      end
    end
  end
end
