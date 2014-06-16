class Six

  class InitializeArgumentError < StandardError
    def message
      "Six.new require hash as pack argument in format {:name_of_pack => PackRules.new}"
    end
  end

end
