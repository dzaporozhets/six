class Book
  attr_accessor :name, :public, :author

  def initialize(name, author, is_public = true)
    @name = name
    @author = author
    @public = is_public
  end

  def author?(author)
    @author == author
  end
end
