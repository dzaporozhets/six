require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  describe "Rules Packs" do 
    class MyRules
      def allowed(object, subject)
        []
      end
    end
    
    describe "namespace usage" do 
      before do 
        @rules = MyRules.new
        @guard = Six
        @guard.add_pack(:global, @rules)
      end

      describe :use do 
        before do 
          @guard.use(:global)
        end

        it { @guard.current_rule_pack.should_not be_nil }
        it { lambda { @guard.use(:noname)}.should raise_error("No such pack") }
      end

      describe :reset_use do 
        before do 
          @guard.use(:global)
          @guard.reset_use
        end

        it { @guard.current_rule_pack.should be_nil }
      end
    end


    describe :add_pack do 
      before do 
        @rules = MyRules.new
        @guard = Six
      end

      it { @guard.add_pack(:global, @rules).should be_true }
      it { lambda { @guard.add_pack(:wrong, nil)}.should raise_error("Wrong Rule Pack. You must provide 'allowed' method") }
    end

    describe :remove_pack do 
      before do 
        @rules = MyRules.new
        @guard = Six
        @guard.add_pack(:global, @rules)
      end

      it { @guard.remove_pack(:global).should be_true }
      it { lambda { @guard.remove_pack(:zzz)}.should raise_error("No such pack") }
    end
  end
end
