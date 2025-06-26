class RoundResult
  attr_reader :current_player, :opponent, :fished_card, :taken_cards, :rank

  def initialize(current_player:, opponent:, rank:, taken_cards: nil, fished_card: nil)
    @current_player = current_player
    @opponent = opponent
    @fished_card = fished_card
    @taken_cards = taken_cards
    @rank = rank
  end
end