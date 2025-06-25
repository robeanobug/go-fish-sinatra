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
  
  def display_hand
    hand.map do |card|
      "#{card.rank} of #{card.suit}"
    end.join(", ")
  end
end