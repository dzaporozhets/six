class BookRules
  def allowed(author, book)
    # check for correct class & nil
    return [] unless author.instance_of?(Author) && book.instance_of?(Book)

    rules = []
    rules << :read_book if book.public || book.author?(author)
    rules << :rate_book if book.public && !book.author?(author)
    rules << :edit_book if book.author?(author)
    rules << :publish_book if book.author?(author) && !book.public
    rules
  end
end
