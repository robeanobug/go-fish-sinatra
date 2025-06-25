require_relative "../lib/game"
require "spec_helper"

RSpec.describe Game do
  let(:player1) { Player.new("Player 1") }
  let(:player2) { Player.new("Player 2") }
  let(:player3) { Player.new('Player 3') }
  let(:player4) { Player.new('Player 4') }

  let(:game) { Game.new}

  def setup_game_with_two_players
    game.add_player(player1)
    game.add_player(player2)
  end

  def setup_game_with_four_players
    setup_game_with_two_players
    game.add_player(player3)
    game.add_player(player4)
  end
  it 'has players' do
    setup_game_with_two_players
    expect(game.players.first).to eq(player1)
    expect(game.players.last).to eq(player2)
  end
  it 'empty? returns true if there are less than two players' do
    expect(game.empty?).to be true
  end
  it 'empty? returns false if there are more than two players' do
    setup_game_with_two_players
    expect(game.empty?).to be false 
  end
  it 'increments a round_counter' do
    setup_game_with_two_players
    expect(game.round_count).to eq 0
    game.play_round
    expect(game.round_count).to eq 1
  end
  describe '#start' do
  it 'should deal out the base hand size to 2 players' do
    setup_game_with_two_players
    game.start
    # binding.irb
    expect(game.players.first.hand.size).to eq(Game::BASE_HAND_SIZE)
  end
  it 'should deal out the small hand size to 4 players' do
    setup_game_with_four_players
    game.start
    expect(game.players.first.hand.size).to eq(Game::SMALL_HAND_SIZE)
  end
end
end
