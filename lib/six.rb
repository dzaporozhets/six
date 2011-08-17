class Six
  class NoPackError < StandardError
    def message
      "No such pack"
    end
  end

  class InvalidPackPassed < StandardError
    def message
      "Wrong Rule Pack. You must provide correct 'allowed' method"
    end
  end

  class << self
    attr_accessor :rules_packs
    attr_accessor :current_rule_pack

    def rules_packs 
      @rules_packs ||= {}
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
    def use(name)
      if pack_exist?(name)
        @current_rule_pack = name.to_sym
        self
      end
    end

    # Same as use but raise exception if no pack found 
    def use!(name)
      use(name) ? self : raise_no_such_pack
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
      rules_packs[name.to_sym] = pack if valid_rules_object?(pack)
    end

    # Same as add_pack but raise exception if pack is invalid 
    def add_pack!(name, pack)
      add_pack(name, pack) || raise_incorrect_pack_object
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

    # Check if object for rule pack is valid 
    # 
    # == Parameters:
    # pack::
    #   Any kind of object responding to allowed method 
    # 
    # == Returns:
    # true or false 
    # 
    def valid_rules_object?(object)
      object.respond_to?(:allowed) &&
        object.send(:allowed, nil, nil).kind_of?(Array)
    rescue 
      false
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
    def allowed?(action, object, subject)
      if current_rule_pack
        rules_packs[current_rule_pack].allowed(object, subject).include?(action)
      else 
        rules_packs.values.map { |rp| rp.allowed(object, subject) }.flatten.include?(action)
      end
    end

    # Reset current used rule pack so auth class use 
    # global allowed? for new request
    def reset_use
      @current_rule_pack = nil
    end

    protected

    def raise_no_such_pack
      raise Six::NoPackError.new
    end

    def raise_incorrect_pack_object
      raise Six::InvalidPackPassed.new
    end
  end
end
