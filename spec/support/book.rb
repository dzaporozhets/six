class Book
  attr_accessor :name, :public, :author

  def initialize(name, author, is_public = true)
    @name, @author, @public = name, author, is_public
  end

  def author?(author)
    @author == author
  end
end
