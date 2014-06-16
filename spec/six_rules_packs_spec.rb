require "./spec/spec_helper"
require "./lib/six"

describe Six do
  # define abilities object
  let (:abilities) { Six.new }

  describe "Rules Packs" do
    let(:rules) { BookRules.new }

    describe "<<" do
      it { (abilities << rules).should be_true }

      it_should_behave_like :valid_abilities do
        let (:abilities) { Six.new }
        let (:rules) { BookRules.new }
        let (:rules_key) { rules.object_id.to_s }
        before { abilities << rules }
      end
    end

    describe :add do
      it { abilities.add(:global, rules).should be_true }
      it { abilities.add(:wrong, nil).should be_false }
    end

    describe :add! do
      it { abilities.add!(:global, rules).should be_true }
    end

    describe "namespace(pack) usage" do
      before { abilities.add(:global, rules) }

      describe :use do
        before { abilities.use(:global) }

        it "should return class object itself when use existing pack" do
          abilities.use(:global).should == abilities
        end

        describe "should set current role pack with selected" do
          it { abilities.current_rule_pack.should == :global }
        end

        it "should return false when trying to use unexisting pack" do
          abilities.use(:noname).should be_false
        end
      end

      describe :use! do
        it "should not raise error if trying to use existing pack" do
          lambda { abilities.use!(:global)}.should_not raise_error
        end

        it "should raise error if trying to use unexisting pack" do
          lambda { abilities.use!(:noname)}.should raise_error(Six::NoPackError)
        end
      end
    end

    describe :reset_use do
      before do
        abilities.use(:global)
        abilities.reset_use
      end

      it "should set current rule pack variable as nil" do
        abilities.current_rule_pack.should be_nil
      end
    end

    context "removing pack" do
      before { abilities.add(:global, rules) }

      describe :remove do
        it { abilities.remove(:global).should be_true }
        it { abilities.remove(:zzz).should be_false }
      end

      describe :remove! do
        it { abilities.remove!(:global).should be_true }
        it { lambda { abilities.remove!(:zzz)}.should raise_error(Six::NoPackError) }
      end
    end

    describe :pack_exist? do
      before { abilities.add(:global, rules) }

      it { abilities.pack_exist?(:global).should be_true }
      it { abilities.pack_exist?(:ufo).should be_false }
    end
  end

  describe "allowed? without subject" do
    it "should default the subject to nil when passing it to the rules" do
      rules = Class.new do
        attr_accessor :subject_passed_to_me
        def allowed(_, b)
          self.subject_passed_to_me = b
          []
        end
      end.new

      abilities.add(:test, rules)

      # default the subject to something
      rules.subject_passed_to_me = Object.new

      # call allowed without a subject
      abilities.allowed?(Object.new, :irrelvant)

      # was the subject passed in as nil?
      rules.subject_passed_to_me.should be_nil
    end
  end

  describe "allowed? without strings or symbols" do

    describe "no ruleset" do
      it "should treat both the same" do
        rules = Class.new do
          def allowed(a, b)
            [:strings_or_symbols_i_dont_care]
          end
        end.new

        abilities.add(:test, rules)

        # call allowed without a subject
        abilities.allowed?(Object.new, :strings_or_symbols_i_dont_care).should be_true
        abilities.allowed?(Object.new, 'strings_or_symbols_i_dont_care').should be_true
      end
    end

    describe "a specific ruleset" do
      it "should treat both the same" do
        rules = Class.new do
          def allowed(a, b)
            [:strings_or_symbols_i_dont_care]
          end
        end.new

        abilities.add(:test, rules)
        abilities.use(:test)

        # call allowed without a subject
        abilities.allowed?(Object.new, :strings_or_symbols_i_dont_care).should be_true
        abilities.allowed?(Object.new, 'strings_or_symbols_i_dont_care').should be_true
      end
    end

  end

  describe "reject" do

    [:apple, :orange].each do |rule_to_reject|

      describe "preventing a rule" do

        it "should block out the rule if it is included in the prevented method of another" do
          allowed_rules = eval("Class.new do
            def allowed(a, b)
              [:#{rule_to_reject}]
            end
          end.new")
          prevented_rules = eval("Class.new do
            def allowed(a, b)
              []
            end
            def prevented(a, b)
              [:#{rule_to_reject}]
            end
          end.new")

          abilities << allowed_rules
          abilities << prevented_rules

          abilities.allowed?(Object.new, rule_to_reject).should be_false
        end

        it "should NOT block out the rule if it is included in the prevented method of another" do
          allowed_rules = eval("Class.new do
            def allowed(a, b)
              [:#{rule_to_reject}]
            end
          end.new")
          prevented_rules = eval("Class.new do
            def allowed(a, b)
              []
            end
            def prevented(a, b)
              []
            end
          end.new")

          abilities << allowed_rules
          abilities << prevented_rules

          abilities.allowed?(Object.new, rule_to_reject).should be_true
        end

      end

    end

  end

end
