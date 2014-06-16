Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six
  attr_reader :rules_packs

  def initialize(rules_packs = [])
    @rules_packs = rules_packs
  end

  def allowed?(object, actions, subject = nil)
    result = if actions.respond_to?(:each)
               actions.all? { |action| action_included?(object, action, subject) }
             else
               action_included?(object, actions, subject)
             end
    result
  end

  protected

  def action_included?(object, action, subject)
    rules = rules_packs.map do |rp| 
                         begin
                           rp.allowed(object, subject)
                         rescue
                           []
                         end
                       end
                       .flatten
                       .map { |a| a.to_s }

    rejection_rules = []

    rules_packs.map do |rule_pack|
      next unless rule_pack.respond_to?(:prevented)
      rejection_rules << rule_pack.prevented(object, subject)
    end
    rejection_rules = rejection_rules.flatten.map { |x| x.to_s } 

    rules = rules.reject { |x| rejection_rules.include?(x.to_s) }
    rules.include?(action.to_s)
  end

end
