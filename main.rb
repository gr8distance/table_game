require 'pry'
require 'parallel'

class Card
  class InvalidType < StandardError; end
  class InvalidNumber < StandardError; end

  attr_reader :type, :number

  def initialize(type:, number:)
    raise InvalidType unless valid_type?(type)
    raise InvalidNumber unless valid_number?(number)

    @type = type
    @number = number
  end

  def royal?
    number == 1 || 10 <= number
  end

  private

  def valid_type?(type)
    %i[spade heart diamond club jocker].include?(type)
  end

  def valid_number?(number)
    (1..13).include?(number) || number.nil?
  end
end

class Deck < Array
  def initialize
    super
    %i[spade heart diamond club].each do |type|
      (1..13).each do |number|
        self << Card.new(type: type, number: number)
      end
    end
  end

  def add_jocker!
    self << Card.new(type: :jocker, number: nil)
  end
end

class Player
  attr_reader :name
  attr_accessor :hand, :score, :hand_name

  def initialize(name:)
    @name = name
  end
end

class Game
  attr_reader :deck, :players
  def initialize(players:)
    @deck = Deck.new.shuffle
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

class Porker < Game
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

class BlackJack < Game
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

aqours = %w[高海千歌 渡辺曜 桜内莉子 黒澤ルビー 国木田花丸 津島善子 松浦果南 黒澤ダイヤ 小原鞠莉].map do |name|
  Player.new(name: name)
end
#
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

player = Player.new(name: 'ug')
def start_game!(players)
  game = BlackJack.new(players: players)
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
