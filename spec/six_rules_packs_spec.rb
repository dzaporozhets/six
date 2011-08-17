require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  describe "Rules Packs" do 
    let(:rules) { BookRules.new }

    describe :add_pack do 
      it { Six.add_pack(:global, rules).should be_true }
      it { Six.add_pack(:wrong, nil).should be_false }
    end

    describe :add_pack! do 
      it { Six.add_pack!(:global, rules).should be_true }
      it { lambda { Six.add_pack!(:wrong, nil)}.should raise_error(Six::InvalidPackPassed) }
    end

    describe "namespace(pack) usage" do 
      before { Six.add_pack(:global, rules) }

      describe :use do 
        before { Six.use(:global) }

        it "should return class object itself when use existing pack" do 
          Six.use(:global).should == Six
        end

        describe "should set current role pack with selected" do 
          it { Six.current_rule_pack.should == :global }
        end

        it "should return false when trying to use unexisting pack" do 
          Six.use(:noname).should be_false
        end
      end

      describe :use! do 
        it "should not raise error if trying to use existing pack" do
          lambda { Six.use!(:global)}.should_not raise_error
        end

        it "should raise error if trying to use unexisting pack" do 
          lambda { Six.use!(:noname)}.should raise_error(Six::NoPackError)
        end
      end
    end

    describe :reset_use do 
      before do 
        Six.use(:global)
        Six.reset_use
      end

      it "should set current rule pack variable as nil" do 
        Six.current_rule_pack.should be_nil
      end
    end

    context "removing pack" do
      before { Six.add_pack(:global, rules) }

      describe :remove_pack do 
        it { Six.remove_pack(:global).should be_true }
        it { Six.remove_pack(:zzz).should be_false }
      end

      describe :remove_pack! do 
        it { Six.remove_pack!(:global).should be_true }
        it { lambda { Six.remove_pack!(:zzz)}.should raise_error(Six::NoPackError) }
      end
    end

    describe :valid_rules_object? do 
      let (:invalid_with_allowed) do 
        Class.new { def allowed; nil; end }.new
      end

      let (:invalid_wo_allowed) do 
        Object.new
      end

      it { Six.valid_rules_object?(BookRules.new).should be_true }
      it { Six.valid_rules_object?(invalid_with_allowed).should be_false }
      it { Six.valid_rules_object?(invalid_wo_allowed).should be_false }
    end

    describe :pack_exist? do 
      before { Six.add_pack(:global, rules) }

      it { Six.pack_exist?(:global).should be_true }
      it { Six.pack_exist?(:ufo).should be_false }
    end
  end
end
