require "spec_helper"
require_relative '../lib/result'
require_relative '../lib/player'
require_relative '../lib/playing_card'

RSpec.describe RoundResult do
  let(:player1) { Player.new('Player 1') }
  let(:player2) { Player.new('Player 2') }
  let(:player3) { Player.new('Player 3') }
  let(:taken_cards) { [PlayingCard.new('Ace', 'Clubs'), PlayingCard.new('Ace', 'Spades')]}
  let(:fished_ace) { PlayingCard.new('Ace', 'Clubs') }
  let(:fished_two) { PlayingCard.new('2', 'Clubs') }

  context 'when current player takes a card from opponent' do
    let(:result) { Result.new(current_player: player1, opponent: player2, rank: 'Ace', taken_cards:) }
    it 'has a current player result' do
      expect(result.current_player_result).to match /You took/i
    end
  end
end