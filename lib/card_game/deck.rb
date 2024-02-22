class CardGame::Deck < Array
  def initialize
    super
    %i[spade heart diamond club].each do |type|
      (1..13).each do |number|
        self << CardGame::Card.new(type: type, number: number)
      end
    end
  end

  def add_jocker!
    self << CardGame::Card.new(type: :jocker, number: nil)
  end
end
