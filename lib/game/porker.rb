module TableGame
  module Game
    class Porker < Base
      def deal!
        super(5)
      end

      def check_hand!(player)
        hand = player.hand
        result = case
                 when royal_straight_flush?(hand) then { score: 9, hand_name: 'ロイヤルストレートフラッシュ' }
                 when straight_flush?(hand) then { score: 8, hand_name: 'ストレートフラッシュ' }
                 when four_of_a_kind?(hand) then { score: 7, hand_name: 'フォーカード' }
                 when full_house?(hand) then { score: 6, hand_name: 'フルハウス' }
                 when flush?(hand) then { score: 5, hand_name: 'フラッシュ' }
                 when straight?(hand) then { score: 4, hand_name: 'ストレート' }
                 when three_of_a_kind?(hand) then { score: 3, hand_name: 'スリーカード' }
                 when two_pair?(hand) then { score: 2, hand_name: 'ツーペア' }
                 when one_pair?(hand) then { score: 1, hand_name: 'ワンペア' }
                 else
                   { score: 0, hand_name: 'ノーカード' }
                 end
        player.score = result[:score]
        player.hand_name = result[:hand_name]
      end

      def drow!(player, drop_card_indexes)
        drop_card_indexes.each do |index|
          player.hand.delete_at(index)
        end
        player.hand += @deck.pop(drop_card_indexes.length)
        player.hand.sort_by!(&:number)
        check_hand!(player)
        puts player
      end

      private

      def royal_straight_flush?(hand)
        numbers = hand.map(&:number).sort
        return false if numbers.uniq.size != 5

        flush?(hand) && (numbers[0] == 1 && numbers[4] == 13 && (numbers[4] - numbers[1] == 3))
      end

      def straight_flush?(hand)
        flush?(hand) && straight?(hand)
      end

      def full_house?(hand)
        head, *tail = hand
        result = check_pair(tail, head)
        result.length == 2 &&
          result.any? { |_, v| v.length == 3 } &&
          result.any? { |_, v| v.length == 2 }
      end

      def flush?(hand)
        hand.map(&:type).uniq.size == 1
      end

      def straight?(hand)
        numbers = hand.map(&:number).sort
        return false if numbers.uniq.size != 5

        (numbers.max - numbers.min) == 4 || (numbers[0] == 1 && numbers[4] == 13 && (numbers[4] - numbers[1] == 3))
      end

      def four_of_a_kind?(hand)
        head, *tail = hand
        result = check_pair(tail, head)
        result.length == 1 && result.first.last.count == 4
      end

      def three_of_a_kind?(hand)
        head, *tail = hand
        result = check_pair(tail, head)
        result.length == 1 && result.first.last.count == 3
      end

      def two_pair?(hand)
        head, *tail = hand
        result = check_pair(tail, head)
        result.length == 2 && result.all? { |_, v| v.length == 2 }
      end

      def one_pair?(hand)
        head, *tail = hand
        result = check_pair(tail, head)
        result.length == 1 && result.first.last.count == 2
      end

      def check_pair(cards, card, acm = {})
        return acm if cards.empty?

        matched = cards.select { |c| c.number == card.number }
        if matched.length >= 1
          head, *tail = (cards - matched)
          check_pair(tail, head, acm.merge({ card.number => matched + [card] }))
        else
          head, *tail = cards
          check_pair(tail, head, acm)
        end
      end
    end
  end
end
