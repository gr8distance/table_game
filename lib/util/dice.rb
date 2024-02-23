module TableGame
  module Util
    class Dice
      def role
        rand(1..6)
      end

      class << self
        def role(number)
          Array.new(number) { new.role }
        end
      end
    end
  end
end
