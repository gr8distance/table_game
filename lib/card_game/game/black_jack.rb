module CardGame
  module Game
    class BlackJack < Base
      def deal!
        super(2)
      end

      private

      def check_hand!(player)
        hand = player.hand.sort_by(&:number)
        case
        when black_jack?(hand)
          player.score = 21
        when hand.sum(&:number) == 2
          player.score == 12
        when in_1_but_not_black_jack?(hand)
          player.score = count_score(hand)
        else
          player.score = count_score(hand)
        end
      end

      private

      def count_score(hand)
        hand.sum do |n|
          case
          when n == 1 then 11
          when n >= 10 then 10
          else
            n
          end
        end
      end

      def black_jack?(hand)
        numbers = hand.map(&:number)
        numbers[0] == 1 && numbers[1] >= 10
      end

      def in_1_but_not_black_jack?(hand)
        hand.map!(&:number).include?(1)
      end
    end
  end
end
