class Player
  attr_reader :name
  attr_accessor :hand
  def initialize(name)
    @name = name
    @hand = []
  end

  def add_cards(cards)
    return hand << cards if cards.is_a?(PlayingCard)
    cards.each { |card| hand << card }
  end
  
  def ranks
    hand.map do |card|
      "#{card.rank}s"
    end.uniq
  end

  def remove_cards(cards)
    self.hand -= cards
  end
end