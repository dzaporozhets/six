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
    abilities.add(:book, BookRules) # true
    ```

4. Thats all. Now you can check abilites. In difference to CanCan it doesnt use current_user method. you manually pass object & subject.

    ```ruby
    abilities.allowed?(@user, :read_book, @book) # true
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
abilities.add(:book, BookRules) # true

# thats all - now we can use it!

abilities.allowed? guest, :read_book, unpublished_book # false
abilities.allowed? guest, :read_book, published_book # true

abilities.allowed? guest, :edit_book, book # false
abilities.allowed? author, :edit_book, book # true

abilities.allowed? guest, :remove_book, book # false
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
  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end
end

# books_controller.rb
class BooksController < ApplicationController
  before_filter :add_abilities
  before_filter :load_author

  def show
    @book = Book.find(params[:id])
    head(404) and return unless can?(:guest, :read_book, @book)
  end

  def edit
    @book = Book.find(params[:id])
    head(404) and return unless can?(@author, :edit_book, @book)
  end

  protected

  def add_abilities
    abilities.add(:book, Book)
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

# View
link_to 'Edit', edit_book_path(book) if can?(@author, :edit_book, book)
```

### :use

```ruby 
abilities.add(:book_rules, BookRules)
abilities.add(:car_rules, CarRules)

abilities.allowed? ... # scan for both BookRules & CarRules & require kind_of check

abilities.use(:book_rules)
abilities.allowed? ... # use rules from BookRules only -> more perfomance
```

### Namespaces

```ruby 
class BookRules
  def self.allowed(author, book)
    [:read_book, :edit_book, :publish_book] 
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
abilities.add(:book, BookRules) # true
abilities.add(:car, CarRules)   # true
abilities.add(:ufo, nil)        # false
abilities.add!(:ufo, nil)       # raise Six::InvalidPackPassed


# use specific pack for rules
abilities.use(:book) # true
abilities.allowed? :anyone, :read_book, book # true
abilities.allowed? :anyone, :drive, car # false

abilities.use(:car)
abilities.allowed? :anyone, :drive, :any      # true
abilities.allowed? :anyone, :read_book, :any  # false

# use reset to return to global usage
abilities.reset_use
abilities.allowed? :anyone, :drive, :any     # true
abilities.allowed? :anyone, :read_book, :any # true

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



