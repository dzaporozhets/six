require "./lib/six"

describe Six do 
  describe "Rules Packs" do 
    class MyRules
      def allowed(object, subject)
        []
      end
    end
    
    describe :use do 
      before do 
        @rules = MyRules.new
        @guard = Six::Guard.instance
        @guard.add_pack(:global, @rules)
      end

      it { @guard.use(:global).should be_true }
      it { lambda { @guard.use(:noname)}.should raise_error("No such pack") }
    end

    describe :add_pack do 
      before do 
        @rules = MyRules.new
        @guard = Six::Guard.instance
      end

      it { @guard.add_pack(:global, @rules).should be_true }
      it { lambda { @guard.add_pack(:wrong, nil)}.should raise_error("Wrong Rule Pack. You must provide 'allowed' method") }
    end

    describe :remove_pack do 
      before do 
        @rules = MyRules.new
        @guard = Six::Guard.instance
        @guard.add_pack(:global, @rules)
      end

      it { @guard.remove_pack(:global).should be_true }
      it { @guard.remove_pack(:zzz).should be_false }
    end
  end
end
