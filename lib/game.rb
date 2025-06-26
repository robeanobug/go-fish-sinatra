class Game
  attr_accessor :players, :round_count, :deck
  REQUIRED_PLAYER_COUNT = 2
  BASE_PLAYER_COUNT = 3
  BASE_HAND_SIZE = 7
  SMALL_HAND_SIZE = 5

  def initialize(deck = CardDeck.new)
    @players = []
    @round_count = 0
    @deck = deck
  end

  def start
    deal_cards
  end

  def add_player(player)
    players << player
  end

  def enough_players?
    players.length >= REQUIRED_PLAYER_COUNT
  end

  def play_round
    self.round_count += 1
  end
  
  def deal_cards
    if players.length > BASE_PLAYER_COUNT
      Game::SMALL_HAND_SIZE.times do
        players.each do |player|
          player.add_cards(deal_card)
        end
      end
    else
      Game::BASE_HAND_SIZE.times do
        players.each do |player|
          player.add_cards(deal_card)
        end
      end
    end
  end

  def deal_card
    deck.deal_card
  end

  def started?
    @deck.cards.count != CardDeck::DECK_COUNT
  end
end
