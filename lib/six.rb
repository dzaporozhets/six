Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six

  def initialize rules = []
    @rules = rules
  end

  def allowed? subject, actions, target = nil
    actions = [actions] unless actions.respond_to?(:each)
    actions.all? { |a| action_included? subject, a, target }
  end

  private

  def rules
    @rules
  end

  def action_included? object, action, subject
    permissions = rules.map do |rp| 
                              begin
                                rp.allowed object, subject
                              rescue
                                []
                              end
                            end.flatten.map { |a| a.to_s }

    permissions_to_reject = rules.select { |r| r.respond_to? :prevented }.map do |rule_pack|
                              rule_pack.prevented(object, subject)
                            end.flatten.map { |x| x.to_s } 

    permissions.reject! { |x| permissions_to_reject.include? x.to_s }
    permissions.include? action.to_s
  end

end
