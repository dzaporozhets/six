require "./lib/six"

describe Six do 
  describe "protection" do 
    class MyRules
      def allowed(object, subject)
        rules = []
        rules << :read_book if object == 1 && subject == 2
        rules
      end
    end

    describe "protect!" do 
      before do 
        @rules = MyRules.new
        @guard = Six::Guard.instance
        @guard.add_pack(:myrules, @rules)
      end

      it "should allow acceess" do 
        @guard.use(:myrules).protect!(:read_book, 1, 2).should be_true
      end

      it "should prevent unauthorized acceess" do 
        @guard.use(:myrules).protect!(:read_book, 2, 2).should be_false
      end
    end
  end
end
