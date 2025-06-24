require_relative "../lib/game"
require "spec_helper"

RSpec.describe Game do
  let(:player1) { Player.new("Player 1") }
  let(:player2) { Player.new("Player 2") }
  let(:game) { Game.new}

  def setup_game_with_players
    game.add_player(player1)
    game.add_player(player2)
  end
  it 'has players' do
    setup_game_with_players
    expect(game.players.first).to eq(player1)
    expect(game.players.last).to eq(player2)
  end
  it 'empty? returns true if there are less than two players' do
    expect(game.empty?).to be true
  end
  it 'empty? returns false if there are more than two players' do
    setup_game_with_players
    expect(game.empty?).to be false 
  end
end
