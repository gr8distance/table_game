module TableGame
  module Util
    class Deck < Array
      def initialize
        super
        %i[spade heart diamond club].each do |type|
          (1..13).each do |number|
            self << TableGame::Util::Card.new(type: type, number: number)
          end
        end
      end

      def add_jocker!
        self << TableGame::Util::Card.new(type: :jocker, number: nil)
      end
    end
  end
end
