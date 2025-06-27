require_relative '../lib/round_result'

class Game
  attr_accessor :players, :round_count, :deck, :player_count, :current_player, :round_results
  BASE_PLAYER_COUNT = 2
  PLAYER_COUNT_THRESHOLD = 4
  BASE_HAND_SIZE = 7
  SMALL_HAND_SIZE = 5

  def initialize(player_count = BASE_PLAYER_COUNT, deck = CardDeck.new)
    @players = []
    @deck = deck
    @player_count = player_count
    @round_results = []
  end

  def start
    deal_cards
    self.current_player = players.first
  end

  def add_player(player)
    players << player
  end

  def enough_players?
    players.length >= player_count
  end

  def play_round(requested_rank, target_player)
    taken_cards = take_cards(requested_rank, target_player)
    fished_card = go_fish unless taken_cards
    round_results << RoundResult.new(current_player:, target_player:, requested_rank:, taken_cards:, fished_card:)
  end
  
  def deal_cards
    if players.length >= PLAYER_COUNT_THRESHOLD
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

  def go_fish
    card = deal_card
    current_player.add_cards(card)
    card
  end

  def started?
    @deck.cards.count != CardDeck::DECK_COUNT
  end

  def take_cards(requested_rank, target_player)
    cards = target_player.hand.select { |card| card.rank == requested_rank }
    unless cards.empty?
      target_player.remove_cards(cards)
      current_player.add_cards(cards)
      return cards
    end
    nil
  end
end
