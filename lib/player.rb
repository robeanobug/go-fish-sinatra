class Player
  attr_reader :name
  attr_accessor :hand, :books
  BOOK_LENGTH = 4
  def initialize(name)
    @name = name
    @hand = []
    @books = []
  end

  def add_cards(cards)
    if cards.is_a?(PlayingCard)
      hand << cards
    else
      cards.each { |card| hand << card }
    end
    create_book_if_possible
  end
  
  def ranks
    hand.map do |card|
      "#{card.rank}s"
    end.uniq
  end

  def remove_cards(cards)
    self.hand -= cards
  end

  def out_of_cards?
    hand.empty?
  end

  def attributes
    {
      "name" => name,
      "hand" => hand,
      "books" => books
    }
  end

  private

  def create_book_if_possible
    book = find_book
    if book
      books << book
      self.hand -= book
    end
  end

  def find_book
    cards_grouped_by_rank = hand.group_by(&:rank)
    cards_grouped_by_rank.values.find do |card_group|
      card_group.length == BOOK_LENGTH
    end
  end
end