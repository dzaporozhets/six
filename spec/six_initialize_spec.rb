require './spec/spec_helper'
require './lib/six'

describe Six, 'initialize' do
  describe 'initalization' do
    before do
      @jim = Author.new('Jim')
      @mike = Author.new('Mike')

      @jims_book = Book.new('The Game', @jim)
      @mikes_book = Book.new('Life', @mike)
    end

    it 'creates authorization object' do
      expect(Six.new).to be_kind_of(Six)
    end

    it 'raises error if invalid argument passed' do
      expect { Six.new('wrong argument') }.to raise_error Six::InitializeArgumentError
    end

    it 'creates authorization object' do
      expect(Six.new(book_rules: BookRules.new)).to be_kind_of(Six)
    end

    it 'creates authorization object' do
      expect(Six.new(book0: BookRules.new, book1: BookRules.new)).to be_kind_of(Six)
    end

    describe 'passing rules on initialization' do
      it_should_behave_like :valid_abilities do
        let(:abilities) { Six.new(book_rules: BookRules.new) }
        let(:rules_key) { :book_rules }
      end
    end
  end
end
