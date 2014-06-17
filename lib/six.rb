Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six

  def initialize(*rules)
    @rules = a_single_array_was_provided?(rules) ? rules[0] : rules
  end

  def allowed? subject, permissions_to_check, target = nil
    permissions_to_check = [permissions_to_check] unless this_is_an_array?(permissions_to_check)
    permissions_to_check.all? { |a| action_included? subject, a, target }
  end

  private

  def rules
    @rules
  end

  def a_single_array_was_provided? rules
    rules.count == 1 && this_is_an_array?(rules[0])
  end

  def this_is_an_array? thing
    thing.respond_to?(:each)
  end

  def action_included? subject, permission_to_check, target
    allowed_permissions_for(subject, target)
      .include? permission_to_check.to_s
  end

  def allowed_permissions_for subject, target
    all_permissions       = all_permissions_for(subject, target)
    permissions_to_reject = permissions_to_reject_for(subject, target)

    all_permissions.reject { |x| permissions_to_reject.include? x.to_s }
  end

  def all_permissions_for subject, target
    permissions = rules.map do |rp| 
                              begin
                                rp.allowed subject, target
                              rescue
                                []
                              end
                            end
    flatten_permissions(permissions)
  end

  def permissions_to_reject_for subject, target
    permissions = rules.map do |r| 
                              begin
                                r.prevented(subject, target)
                              rescue
                                []
                              end
                            end
    flatten_permissions permissions
  end

  def flatten_permissions permissions
    permissions.flatten.map { |a| a.to_s }
  end

end
