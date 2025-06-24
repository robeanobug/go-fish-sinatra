require_relative "../lib/game"
require "spec_helper"

RSpec.describe Game do
  let(:player1) { Player.new("Player 1") }
  let(:player2) { Player.new("Player 2") }
  let(:game) { Game.new}

  before do
    game.add_player(player1)
    game.add_player(player2)
  end
  it 'has players' do
    expect(game.players.first).to eq(player1)
    expect(game.players.last).to eq(player2)
  end
end