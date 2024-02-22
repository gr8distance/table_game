require 'pry'
require 'parallel'

require './lib/card_game/player'
require './lib/card_game/card'
require './lib/card_game/deck'
require './lib/card_game/game/base'
require './lib/card_game/game/porker'
require './lib/card_game/game/black_jack'

aqours = %w[高海千歌 渡辺曜 桜内莉子 黒澤ルビー 国木田花丸 津島善子 松浦果南 黒澤ダイヤ 小原鞠莉].map do |name|
  CardGame::Player.new(name: name)
end

# def start_game!(players)
#   game = Porker.new(players: players)
#   game.deal!
#   game.check_hands
#   game
# end
#
# game = start_game!(aqours)
# while game.players.sort_by(&:score).last.score != 9
#   game = start_game!(aqours)
# end
# game.players.sort_by(&:score).each do |player|
#   p player
# end

player = CardGame::Player.new(name: 'ug')
def start_game!(players)
  game = CardGame::Game::BlackJack.new(players: players)
  game.deal!
  game.check_hands
  game
end

scores = []
Array.new(1_000_00) do |i|
  game = start_game!([player])
  scores << { score: game.players[0].score, index: i }
end

grouped = scores
    .sort_by { |score| score[:score] }
    .group_by { |score| score[:score] }
p Parallel
    .map(grouped) { |k, v| [k, v.length] }
    .to_h

# while game.players.sort_by(&:score).last.score != 21
#   i += 1
#   game = start_game!([player])
# end
# puts i
# game.players.sort_by(&:score).each do |player|
#   p player
# end
