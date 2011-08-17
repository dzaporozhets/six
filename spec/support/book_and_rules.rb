class BookRules
  def allowed(object, subject)
    rules = []
    rules << :read_book if object == 1 && subject == 2
    rules << :edit_book if object == 1 && subject == 2
    rules
  end
end

