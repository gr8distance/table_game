module TableGame
  module Game
    class Base
      attr_reader :deck, :players
      def initialize(players:)
        @deck = TableGame::Deck.new.shuffle
        @players = players
      end

      def deal!(number)
        @players.each do |player|
          player.hand = @deck.pop(number).sort_by(&:number)
        end
      end

      def check_hands
        @players.each do |player|
          check_hand!(player)
        end
      end

      private

      def check_hand!(player)
        raise NotImplementedError
      end
    end
  end
end
