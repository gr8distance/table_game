class CardGame::Card
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
