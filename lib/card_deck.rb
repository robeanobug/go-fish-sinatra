require_relative 'playing_card'

class CardDeck
  attr_accessor :cards
  DECK_COUNT = 52 
  def initialize
    @cards = build_deck
  end

  def build_deck
    PlayingCard::RANKS.map do |rank|
      PlayingCard::SUITS.map do |suit|
        PlayingCard.new(rank, suit)
      end
    end.flatten
  end

  def deal_card
    cards.pop
  end

  def add_card(card)
    cards.push(card)
  end

  def shuffle!
    cards.shuffle!
  end

  def empty?
    cards.empty?
  end

  def attributes
    {
      "cards" => cards.map { |card| card.attributes}
    }
  end
end

