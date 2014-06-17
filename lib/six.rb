Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six

  def initialize rules = []
    @rules = rules
  end

  def allowed? subject, permissions_to_check, target = nil
    #permissions_to_check = [permissions_to_check] unless permissions_to_check.respond_to?(:each)
    #permissions_to_check.all? { |a| action_included? subject, a, target }
    false
  end

  private

  def rules
    @rules
  end

  def action_included? subject, permission_to_check, target
    permissions = rules.map do |rp| 
                              begin
                                rp.allowed subject, target
                              rescue
                                []
                              end
                            end.flatten.map { |a| a.to_s }

    permissions_to_reject = rules.select { |r| r.respond_to? :prevented }.map do |rule_pack|
                              rule_pack.prevented(subject, target)
                            end.flatten.map { |x| x.to_s } 

    permissions.reject! { |x| permissions_to_reject.include? x.to_s }
    permissions.include? permission_to_check.to_s
  end

end
