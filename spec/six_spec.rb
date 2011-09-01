require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  it_should_behave_like :valid_abilities do 
    let (:abilities) { Six.new }
    let (:rules) { BookRules.new }
    before { abilities.add(:book_rules, rules) }
  end
end
