require "spec_helper"
require_relative '../lib/round_result'
require_relative '../lib/player'
require_relative '../lib/playing_card'

RSpec.describe RoundResult do
  let(:player1) { Player.new('Player 1') }
  let(:player2) { Player.new('Player 2') }
  let(:player3) { Player.new('Player 3') }
  let(:taken_cards) { [PlayingCard.new('Ace', 'Clubs'), PlayingCard.new('Ace', 'Spades')]}
  let(:fished_ace) { PlayingCard.new('Ace', 'Clubs') }
  let(:fished_two) { PlayingCard.new('Two', 'Clubs') }

  context 'when current player takes a card from target player' do
    let(:result) { RoundResult.new(current_player: player1, target_player: player2, requested_rank: 'Ace', taken_cards:) }
    it 'has a current player result' do
      expect(result.current_player_round_result).to match /You took/i
    end
    it 'has a game response for bystanders' do
      expect(result.bystanders_game_response).to include('asked', 'for')
    end
    it 'has a game round result for bystanders' do
      expect(result.bystanders_round_result).to include('took')
    end
  end
  context 'when current player goes fish' do
    let(:result) { RoundResult.new(current_player: player1, target_player: player2, requested_rank: 'Ace', fished_card: fished_two) }
    it 'has a game round result for bystanders' do
      expect(result.bystanders_round_result).to include('fish')
    end
    it 'has a current player action' do
      expect(result.current_player_action).to include('You drew')
    end
  end
  context 'when a current player did not have cards at the beginning of the turn' do
    let(:result) { RoundResult.new(current_player: player1, target_player: player2, requested_rank: nil, fished_card: fished_two) }
    it 'should say the current player is out of cards and drew a card' do
      expect(result.current_player_action).to include("out of cards")
    end
  end

  context 'handle winner output' do
    let(:result) { RoundResult.new(winners: [player1]) }
    it 'should display a winner if there is a winner' do
      expect(result.winner_output).to include(player1.name, "winner")
    end
    let(:result) { RoundResult.new(winners: [player1, player2]) }
    it 'should display a tie if tie' do
      expect(result.winner_output).to include(player1.name, player2.name,  "tie")
    end
  end
end