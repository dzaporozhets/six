## Six - is a ultra simple authorization gem for ruby!

### Installation

```ruby
  gem install six
```


### QuickStart

4 steps:

1. create abilities object

    ```ruby
      abilites = Six.new
    ```

2. create object/class with allowed method - here you'll put conditions to define abilities

    ```ruby
    class BookRules
      def self.allowed(author, book)
        [:read_book, :edit_book]
      end
    end
    ```

3. Add object with your rules to abilities

    ```ruby
    abilities.add_pack(:book, BookRules) # true
    ```

4. Thats all. Now you can check abilites. In difference to CanCan it doesnt use current_user method. you manually pass object & subject.

    ```ruby
    abilities.allowed?(:read_book, User.first, Book.last) # true
    ```


### Advanced Usage

```ruby 
class BookRules
  # All authorization works on objects with method 'allowed'
  # No magic behind the scene
  # You can put this method to any class or object you want
  # It should always return array
  # And be aready to get nil in args
  def self.allowed(author, book)
    rules = []

    # good practice is to check for object type
    return rules unless book.instance_of?(Book)

    rules << :read_book if book.published? 
    rules << :edit_book if book.author?(author)

    # you are free to write any conditions you need
    if book.author?(author) && book.is_approved? # ....etc...
      rules << :publis_book 
    end

    rules # return array of abilities
  end
end

# create abilites object
abilites = Six.new

# Add rules to namespace ':book' & global namespace
abilities.add_pack(:book, BookRules) # true

# thats all - now we can use it!

abilities.allowed? :read_book, nil, nil # false
abilities.allowed? :read_book, nil, published_book # true

abilities.allowed? :edit_book, nil, book # false
abilities.allowed? :edit_book, author, author.books.first # true

abilities.allowed? :remove_book, nil, nil # false
```

### Usage with Rails

```ruby 
# Controller

# application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :abilities, :can?

  protected 

  def abilities
    @abilities ||= Six.new
  end

  # simple delegate method for controller & view
  def can?(action, object, subject)
    abilities.allowed?(action, object, subject)
  end
end

# books_controller.rb
class BooksController < ApplicationController
  before_filter :add_abilities
  before_filter :load_author

  def show
    @book = Book.find(params[:id])
    head(404) and return unless can?(:read_book, nil, @book)
  end

  def edit
    @book = Book.find(params[:id])
    head(404) and return unless can?(:edit_book, @author, @book)
  end

  protected

  def add_abilities
    abilities.add_pack(:book, Book)
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
    return rules unless book && book.instance_of?(Book)
    rules << :read_book if subject.public?
    rules << :edit_book if object && object.id == subject.author_id
    rules
  end
end

# View
link_to 'Edit', edit_book_path(book) if can?(:edit_book, @author, book)
```


### Namespaces

```ruby 
class BookRules
  def self.allowed(author, book)
    [:read_book, :edit_book, :publis_book] 
  end
end

class CarRules
  def self.allowed(driver, car)
    [:drive, :sell] 
  end
end

# init object
abilities = Six.new

# add packs
abilities.add_pack(:book, BookRules) # true
abilities.add_pack(:car, CarRules)   # true
abilities.add_pack(:ufo, nil)        # false
abilities.add_pack!(:ufo, nil)       # raise Six::InvalidPackPassed


# use specific pack for rules
abilities.use(:book) # true
abilities.allowed? :read_book, nil, nil # true
abilities.allowed? :drive, nil, nil # false

abilities.use(:car)
abilities.allowed? :drive, nil, nil      # true
abilities.allowed? :read_book, nil, nil  # false

# use reset to return to global usage
abilities.reset_use
abilities.allowed? :drive, nil, nil     # true
abilities.allowed? :read_book, nil, nil # true

# different use methods
abilities.use(:ufo)  # false
abilities.use!(:ufo) # raise Six::NoPackError


# remove pack
abilities.remove(:book)  # true
abilities.remove(:ufo)   # false
abilities.remove!(:ufo)  # raise Six::NoPackError

abilities.use(:car)  # true
abilities.current_rule_pack # :car

```



