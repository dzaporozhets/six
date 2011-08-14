## Six - is a authorization gem for ruby!

### Installation

```ruby
  gem install six
```

### Usage

```ruby 
class BookRules
  # All authorization works on objects with method 'allowed'
  # No magic behind the scene
  # You can put this method to any class you want
  # It should always return array 
  def self.allowed(author, book)
    rules = []

    # good practice is to check for object type
    return rules unless book.instance_of?(Book)

    rules << :read_book if book.published? 
    rules << :edit_book if author && author.id == book.author_id

    # you are free to write any conditions you need
    if author && author.id == book.author_id && book.is_approved? # ....etc...
      rules << :publis_book 
    rules
  end
end

# Add rules to namespace ':book' & global namespace
Six.add_pack(:book, BookRules)

Six.allowed? :read_book, nil, nil # false
Six.allowed? :read_book, nil, published_book # true

Six.allowed? :edit_book, nil, nil # false
Six.allowed? :edit_book, author, author.books.first # true
```

### Usage with Rails

```ruby 
# Controller
class BooksController < ApplicationController
  before_filter :add_abilities
  before_filter :load_author

  def show
    @book = Book.find(params[:id])
    head(404) and return unless allowed?(:read_book, nil, @book)
  end

  def edit
    @book = Book.find(params[:id])
    head(404) and return unless allowed?(:edit_book, @author, @book)
  end

  protected

  def add_abilities
    Six.add_pack(:book, Book)
  end

  def allowed?(action, object, subject)
    Six.allowed?(action, object, subject)
  end

  def load_author
    @author = Author.find_by_id(params[:author_id])
  end
end


# Model
class Book < ActiveRecord::Base
  belongs_to :author

  def self.allowed(object, subject)
    rules = []
    return rules unless book.instance_of?(Book)
    rules << :read_book if subject.public?
    rules << :edit_book if object && object.id == subject.author_id
    rules
  end
end

# Helper
module ApplicationHelper
  def can?(action, object, subject)
    Six.allowed?(action, object, subject)
  end
end


# View
link_to 'Edit', edit_book_path(book) if can?(:edit_book, @author, book)
```
