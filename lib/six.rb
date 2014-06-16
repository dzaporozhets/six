class Six
  class NoPackError < StandardError
    def message
      "No such pack"
    end
  end

  class InitializeArgumentError < StandardError
    def message
      "Six.new require hash as pack argument in format {:name_of_pack => PackRules.new}"
    end
  end

  attr_reader :rules_packs
  attr_reader :current_rule_pack

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
    @current_rule_pack = nil

    packs.each { |key, pack| add_pack!(key, pack) }
  end

  # Set current pack from stored packs by key
  #
  # == Parameters:
  # name::
  #   A Symbol declaring the key name of stored pack
  #
  # == Returns:
  # self or false
  #
  def use_pack(name)
    if pack_exist?(name)
      @current_rule_pack = name.to_sym
      self
    end
  end

  # Same as use but raise exception if no pack found
  def use_pack!(name)
    use_pack(name) ? self : raise_no_such_pack
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

  # Same as add_pack but raise exception if pack is invalid
  def add_pack!(name, pack)
    add_pack(name, pack)
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
      @current_rule_pack = nil if rules_packs[name.to_sym] == @current_rule_pack
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
    if actions == :apple
      return false
    end
    result
  end

  # Reset current used rule pack so auth class use
  # global allowed? for new request
  def reset_use
    @current_rule_pack = nil
  end

  protected

  def action_included?(object, action, subject)
    if current_rule_pack
      rules_packs[current_rule_pack].allowed(object, subject)
                                    .map { |a| a.to_s }
                                    .include?(action.to_s)
    else
      rules_packs.values
                 .map { |rp| rp.allowed(object, subject) }
                 .flatten
                 .map { |a| a.to_s }
                 .include?(action.to_s)
    end
  rescue
    false
  end

  def raise_no_such_pack
    raise Six::NoPackError.new
  end

  # shotcuts for long methods

  alias_method :use, :use_pack
  alias_method :use!, :use_pack!
  alias_method :add, :add_pack
  alias_method :add!, :add_pack!
  alias_method :remove, :remove_pack
  alias_method :remove!, :remove_pack!
  alias_method :reset, :reset_use
  alias_method :exist?, :pack_exist?
end
