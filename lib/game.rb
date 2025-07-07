require_relative '../lib/round_result'
require_relative '../lib/card_deck'
require_relative '../lib/player'
class Game
  attr_accessor :players, :round_count, :deck, :player_count, :current_player, :rounds_results
  BASE_PLAYER_COUNT = 2
  PLAYER_COUNT_THRESHOLD = 4
  BASE_HAND_SIZE = 7
  SMALL_HAND_SIZE = 5

  def initialize(player_count = BASE_PLAYER_COUNT, deck = CardDeck.new)
    @players = []
    @deck = deck
    @player_count = player_count
    @rounds_results = []
  end

  def start
    deck.shuffle!
    deal_cards
    self.current_player = players.first
  end

  def over?
    deck.empty? && players.all? { |player| player.out_of_cards? }
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
    rounds_results << RoundResult.new(current_player:, target_player:, requested_rank:, taken_cards:, fished_card:)
    return rounds_results << RoundResult.new(winners: find_winners) if over?
    change_turns_if_possible(requested_rank, fished_card)
    rounds_results
  end
  
  def deal_cards
    if players.length >= PLAYER_COUNT_THRESHOLD
      deal_less_cards
    else
      deal_more_cards
    end
  end

  def deal_less_cards
    Game::SMALL_HAND_SIZE.times do
      players.each do |player|
        player.add_cards(deal_card)
      end
    end
  end

  def deal_more_cards
    Game::BASE_HAND_SIZE.times do
      players.each do |player|
        player.add_cards(deal_card)
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

  def change_turns_if_possible(requested_rank, fished_card)
    return if fished_card.nil?
    return if requested_rank.nil?
    unless requested_rank == fished_card.rank
      current_player_index = players.index(current_player) + 1
      self.current_player = players[current_player_index % players.count]
    end
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
  
  def find_winners
    winner = players.max { |player| player.books.count }
    players.select { |player| winner.books.count == player.books.count }
  end

  def attributes(player_name)
    {
      "hand" => players.find { |player| player.name == player_name }.display_hand,
      "players" => players.map { |player| player.attributes },
      "player_count" => player_count,
      "rounds_results" =>  rounds_results
    }
  end
end
