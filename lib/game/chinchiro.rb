module TableGame
  module Game
    class Chinchiro < Base
      def initialize(players:)
        @players = players
      end

      def play(player)
        roles = TableGame::Util::Dice.role(3)
        player.hand = roles
        self.class.check_hand!(player, roles)
      end

      class << self
        def check_hand!(player, roles)
          score = case
                  when roles.sort == [1, 2, 3] then { score: 0.5, hand_name: 'ヒフミ' }
                  when roles.sort == [4, 5, 6] then { score: 2, hand_name: 'シゴロ' }
                  when roles.uniq.size == 1
                    case roles.first
                    when 1 then { score: 5, hand_name: 'ピンゾロ' }
                    when 2 then { score: 3, hand_name: 'ニゾロ' }
                    when 3 then { score: 3, hand_name: 'サンゾロ' }
                    when 4 then { score: 3, hand_name: 'ヨンゾロ' }
                    when 5 then { score: 3, hand_name: 'ゴゾロ' }
                    when 6 then { score: 3, hand_name: 'ロクゾロ' }
                    end
                  when roles.uniq.size == 2
                    hand = roles.reduce({}) do |acm, num|
                      acm[num] ||= 0
                      acm[num] += 1
                      acm
                    end.find do |value|
                      value.length == 1
                    end.to_a.first
                    { score: 1, hand_name: "#{hand}の目" }
                  else
                    { score: 0, hand_name: '目無し' }
                  end
          player.score = score[:score]
          player.hand_name = score[:hand_name]
          player
        end
      end
    end
  end
end
