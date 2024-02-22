module CardGame
  class Player
    attr_reader :name
    attr_accessor :hand, :score, :hand_name

    def initialize(name:)
      @name = name
    end
  end
end
