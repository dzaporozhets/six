require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  describe :allowed? do 
    let (:rules) { BookRules.new }
    before { Six.add_pack(:book_rules, rules) }
    
    before do 
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    def allowed?(action, object, subject) 
      # reset use
      Six.reset_use

      # validate work of both global & local namespaces
      Six.allowed?(action, object, subject) && 
        Six.use(:book_rules).allowed?(action, object, subject)
    end

    describe "should return true or false depend on access" do 
      context :read_book do 
        it { allowed?(:read_book, @jim, @jims_book).should be_true }
        it { allowed?(:read_book, @mike, @mikes_book).should be_true }
        it { allowed?(:read_book, @jim, @mikes_book).should be_true }
        it { allowed?(:read_book, @mike, @jims_book).should be_true }
      end

      context :rate_book do 
        it { allowed?(:rate_book, @jim, @jims_book).should be_false }
        it { allowed?(:rate_book, @mike, @mikes_book).should be_false }
        it { allowed?(:rate_book, @jim, @mikes_book).should be_true }
        it { allowed?(:rate_book, @mike, @jims_book).should be_true }
      end

      context :edit_book do 
        it { allowed?(:edit_book, @jim, @jims_book).should be_true }
        it { allowed?(:edit_book, @mike, @mikes_book).should be_true }
        it { allowed?(:edit_book, @jim, @mikes_book).should be_false }
        it { allowed?(:edit_book, @mike, @jims_book).should be_false }
      end

      context :publish_book do 
        it { allowed?(:publish_book, @jim, @jims_book).should be_false }
        it { allowed?(:publish_book, @mike, @mikes_book).should be_false }
        it { allowed?(:publish_book, @jim, @mikes_book).should be_false }
        it { allowed?(:publish_book, @mike, @jims_book).should be_false }
      end
    end
  end
end
