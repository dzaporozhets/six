require "./spec/spec_helper"
require "./lib/six"

describe Six, "initialize" do 
  describe "initalization" do 
    before do 
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    it "should create authorization object" do 
      Six.new.should be_kind_of(Six)
    end

    it "should raise error if invalid argument passed" do 
      lambda { Six.new("wrong argument") }.should raise_error Six::InitializeArgumentError
    end

    it "should create authorization object" do 
      Six.new(:book_rules => BookRules.new).should be_kind_of(Six)
    end

    it "should create authorization object" do 
      Six.new(:book0 => BookRules.new, :book1 => BookRules.new).should be_kind_of(Six)
    end

    describe "passing rules on initialization" do 
      it_should_behave_like :valid_abilities do 
        let(:abilities) { Six.new(:book_rules => BookRules.new) }
      end
    end
  end
end
