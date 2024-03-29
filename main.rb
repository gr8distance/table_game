require 'pry'
require 'parallel'

require './lib/util/player'
require './lib/util/card'
require './lib/util/deck'
require './lib/util/dice'
require './lib/game/base'
require './lib/game/porker'
require './lib/game/black_jack'
require './lib/game/chinchiro'

aqours = %w[高海千歌 渡辺曜 桜内莉子 黒澤ルビー 国木田花丸 津島善子 松浦果南 黒澤ダイヤ 小原鞠莉].map do |name|
  TableGame::Util::Player.new(name: name)
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

#player = TableGame::Util::Player.new(name: 'ug')
#def start_game!(players)
#  game = TableGame::Util::Game::BlackJack.new(players: players)
#  game.deal!
#  game.check_hands
#  game
#end
#
#scores = []
#Array.new(1_000_00) do |i|
#  game = start_game!([player])
#  scores << { score: game.players[0].score, index: i }
#end
#
#grouped = scores
#    .sort_by { |score| score[:score] }
#    .group_by { |score| score[:score] }
#p Parallel
#    .map(grouped) { |k, v| [k, v.length] }
#    .to_h

# while game.players.sort_by(&:score).last.score != 21
#   i += 1
#   game = start_game!([player])
# end
# puts i
# game.players.sort_by(&:score).each do |player|
#   p player
# end


def weighted_sample(options, weights)
  total_weight = weights.sum
  target = rand * total_weight
  cumulative_weight = 0

  options.each_with_index do |option, index|
    cumulative_weight += weights[index]
    return option if target < cumulative_weight
  end
end

options = ['A', 'B', 'C']
weights = [1, 3, 6]  # Aが出る確率はBの1/3、Cの1/6

result = Array.new(100_000) do
  weighted_sample(options, weights)
end.group_by { |a| a }.map { |k ,v| [k, v.length] }.to_h

player = TableGame::Util::Player.new(name: 'UG')
game = TableGame::Game::Chinchiro.new(players: [player])

try = 100
lo = 10000
results = Array.new(try) do
  scores = Array.new(lo) do
    game.play(player)
    {
      score: player.score,
      hand: player.hand,
      hand_name: player.hand_name
    }
  end
  scores.group_by { |s| s[:score] }.map { |k, v| [k, v.count] }.sort_by(&:first).to_h
end

keys = results.first.keys
hoge = results.reduce({}) do |acm, r|
  keys.each do |key|
    acm[key] ||= []
    acm[key] = acm[key] + [r[key].to_i]
  end
  acm
end.map do |key, value|
  [key, value.sum / try * 0.01]
end.to_h
binding.pry
