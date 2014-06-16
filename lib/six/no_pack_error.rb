class Six

  class NoPackError < StandardError
    def message
      "No such pack"
    end
  end

end
