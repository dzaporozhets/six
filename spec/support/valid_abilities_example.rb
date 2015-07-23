shared_examples :valid_abilities do
  describe :allowed? do 
    before do 
      @jim = Author.new("Jim")
      @mike = Author.new("Mike")

      @jims_book = Book.new("The Game", @jim)
      @mikes_book = Book.new("Life", @mike)
    end

    def allowed?(action, object, subject) 
      # reset use
      abilities.reset_use

      # validate work of both global & local namespaces
      abilities.allowed?(action, object, subject) && 
        abilities.use(rules_key).allowed?(action, object, subject)
    end

    describe "should return true or false depend on access" do 
      context :read_book do 
        it { allowed?(@jim,  :read_book, @jims_book).should be_truthy }
        it { allowed?(@mike, :read_book, @mikes_book).should be_truthy }
        it { allowed?(@jim,  :read_book, @mikes_book).should be_truthy }
        it { allowed?(@mike, :read_book, @jims_book).should be_truthy }
      end

      context :rate_book do 
        it { allowed?(@jim,  :rate_book, @jims_book).should be_falsey }
        it { allowed?(@mike, :rate_book, @mikes_book).should be_falsey }
        it { allowed?(@jim,  :rate_book, @mikes_book).should be_truthy }
        it { allowed?(@mike, :rate_book, @jims_book).should be_truthy }
      end

      context :edit_book do 
        it { allowed?(@jim, :edit_book, @jims_book).should be_truthy }
        it { allowed?(@mike,:edit_book,  @mikes_book).should be_truthy }
        it { allowed?(@jim, :edit_book, @mikes_book).should be_falsey }
        it { allowed?(@mike,:edit_book,  @jims_book).should be_falsey }
      end

      context :publish_book do 
        it { allowed?(@jim, :publish_book, @jims_book).should be_falsey }
        it { allowed?(@mike,:publish_book,  @mikes_book).should be_falsey }
        it { allowed?(@jim, :publish_book, @mikes_book).should be_falsey }
        it { allowed?(@mike,:publish_book,  @jims_book).should be_falsey }
      end

      context 'passing multiple actions' do 
        it { allowed?(@jim, [:read_book, :edit_book], @jims_book).should be_truthy }
        it { allowed?(@jim, [:ead_book,  :publish_book, :edit_book], @jims_book).should be_falsey }
        it { allowed?(@mike, [:read_book, :edit_book], @mikes_book).should be_truthy }
        it { allowed?(@mike, [:rate_book, :publish_book, :edit_book], @mikes_book).should be_falsey }
      end
    end
  end
end
