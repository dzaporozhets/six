require "rubygems"
require "bundler/setup"
require "singleton"

module Six
  class Guard
    include Singleton

    attr_accessor :rules_packs
    attr_accessor :current_rule_pack

    def initialize 
      @rules_packs = {}
    end

    def use(name)
      @current_rule_pack = rules_packs[name.to_sym] if pack_exist?(name)
      self
    end

    def add_pack(name, pack)
      rules_packs[name.to_sym] = pack if valid_rules_object?(pack)
    end

    def remove_pack(name)
      rules_packs.delete(name.to_sym)
    end

    def valid_rules_object?(object)
      object.respond_to?(:allowed) || 
        raise("Wrong Rule Pack. You must provide 'allowed' method")
    end

    def pack_exist?(name)
      rules_packs.has_key?(name.to_sym) || 
        raise("No such pack")
    end

    def protect!(action, object, subject)
      current_rule_pack.allowed(object, subject).include?(action)
    end
  end
end
