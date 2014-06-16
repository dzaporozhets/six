Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six
  attr_reader :rules_packs

  def initialize(packs={})
    @rules_packs = {}

    packs.each { |key, pack| add_pack!(key, pack) }
  end

  def add_pack(name, pack)
    rules_packs[name.to_sym] = pack
  end

  def <<(pack)
    add_pack!(pack.object_id.to_s, pack)
  end

  def pack_exist?(name)
    rules_packs.has_key?(name.to_sym)
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
    rules = rules_packs.values
                       .map do |rp| 
                         begin
                           rp.allowed(object, subject)
                         rescue
                           []
                         end
                       end
                       .flatten
                       .map { |a| a.to_s }

    rejection_rules = []

    rules_packs.values.map do |rule_pack|
      next unless rule_pack.respond_to?(:prevented)
      rejection_rules << rule_pack.prevented(object, subject)
    end
    rejection_rules = rejection_rules.flatten.map { |x| x.to_s } 

    rules = rules.reject { |x| rejection_rules.include?(x.to_s) }
    rules.include?(action.to_s)
  rescue
    false
  end

  alias_method :add_pack!, :add_pack
  alias_method :add, :add_pack
  alias_method :add!, :add_pack!
  alias_method :remove, :remove_pack
  alias_method :remove!, :remove_pack!
  alias_method :exist?, :pack_exist?
end
