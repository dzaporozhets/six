Dir[File.dirname(__FILE__) + '/six/*.rb'].each { |f| require f }

class Six
  attr_reader :rules_packs

  # Initialize ability object
  #
  # == Parameters:
  # packs::
  #   A Hash or rules to add with initializtion
  #
  # == Returns:
  # self
  #
  def initialize(packs={})
    raise InitializeArgumentError.new unless packs.kind_of?(Hash)

    @rules_packs = {}

    packs.each { |key, pack| add_pack!(key, pack) }
  end

  # Add pack to authorization class
  #
  # == Parameters:
  # name::
  #   A Symbol declaring the key name of stored pack
  # pack::
  #   Any kind of object responding to allowed method
  #
  # == Returns:
  # true or false
  #
  def add_pack(name, pack)
    rules_packs[name.to_sym] = pack
  end

  # Add pack to authorization class w/o key
  #
  # == Parameters:
  # pack::
  #   Any kind of object responding to allowed method
  #
  # == Returns:
  # true or raise exception
  #
  def <<(pack)
    add_pack!(pack.object_id.to_s, pack)
  end

  # Remove pack from authorization class
  #
  # == Parameters:
  # name::
  #   A Symbol declaring the key name of stored pack
  #
  # == Returns:
  # true or false
  #
  def remove_pack(name)
    if pack_exist?(name)
      rules_packs.delete(name.to_sym)
    end
  end

  # Same as remove_pack but raise exception if pack wasnt found
  def remove_pack!(name)
    remove_pack(name) || raise_no_such_pack
  end

  # Check if authorization class has pack with such name
  #
  # == Parameters:
  # name::
  #   A Symbol declaring the key name of stored pack
  #
  # == Returns:
  # true or false
  #
  def pack_exist?(name)
    rules_packs.has_key?(name.to_sym)
  end

  # Check if authorization class allow access for object to subject
  # using selected pack or all stored.
  # Basically this method
  # 1. send :allowed for every stored object in packs and pass object & subject
  # 2. check if any of results include allowed action
  #
  # == Parameters:
  # action::
  #   Action name to check for access
  # object::
  #   object trying to access resource
  # subject::
  #   resource
  #
  # == Returns:
  # true or false
  #
  def allowed?(object, actions, subject = nil)
    # if multiple actions passed
    # check all actions to be allowed
    result = if actions.respond_to?(:each)
               actions.all? { |action| action_included?(object, action, subject) }
             else
               # single action check
               action_included?(object, actions, subject)
             end
    #rules_packs.each do |rules_pack|
      #if rules_pack[1].respond_to?(:prevented)
        #return false if rules_pack[1].prevented(nil, nil).include? 
        #return false 
      #end
    #end
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

  def raise_no_such_pack
    raise Six::NoPackError.new
  end

  # shotcuts for long methods

  alias_method :add_pack!, :add_pack
  alias_method :add, :add_pack
  alias_method :add!, :add_pack!
  alias_method :remove, :remove_pack
  alias_method :remove!, :remove_pack!
  alias_method :exist?, :pack_exist?
end
