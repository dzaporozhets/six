Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six
  attr_reader :rules

  def initialize(rules = [])
    @rules = rules
  end

  def allowed?(subject, actions, target = nil)
    result = if actions.respond_to?(:each)
               actions.all? { |action| action_included?(subject, action, target) }
             else
               action_included?(subject, actions, target)
             end
    result
  end

  protected

  def action_included?(object, action, subject)
    permissions = rules.map do |rp| 
                         begin
                           rp.allowed(object, subject)
                         rescue
                           []
                         end
                       end
                       .flatten
                       .map { |a| a.to_s }

    rejection_rules = []

    rules.map do |rule_pack|
      next unless rule_pack.respond_to?(:prevented)
      rejection_rules << rule_pack.prevented(object, subject)
    end
    rejection_rules = rejection_rules.flatten.map { |x| x.to_s } 

    permissions = permissions.reject { |x| rejection_rules.include?(x.to_s) }
    permissions.include?(action.to_s)
  end

end
