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
  it 'enough_players? returns false if there are less than two players' do
    expect(game.enough_players?).to be false
  end
  it 'enough_players? returns false if there are more than two players' do
    setup_game_with_two_players
    expect(game.enough_players?).to be true 
  end
  describe '#play_round' do
    let(:ace_hearts) { PlayingCard.new('Ace', 'Hearts') }
    let(:king_hearts) { PlayingCard.new('King', 'Hearts') }
    let(:ace_clubs) { PlayingCard.new('Ace', 'Clubs') }
    let(:king_clubs) { PlayingCard.new('King', 'Clubs') }
    let(:ace_diamonds) { PlayingCard.new('Ace', 'Diamonds') }
    let(:ace_spades) { PlayingCard.new('Ace', 'Spades') }
    let(:two_hearts) { PlayingCard.new('Two', 'Hearts') }

    before do
      setup_game_with_two_players
    end
    context "When the current player's turn stays" do
      it 'current player gets cards from opponent' do
        game.start
        player1.hand = [ace_hearts, king_hearts]
        player2.hand = [ace_clubs, king_clubs]
        result = game.play_round('Ace', player2)

        expect(player1.hand).to include(ace_hearts, king_hearts, ace_clubs)
        expect(player2.hand).to include(king_clubs)
        expect(result.last.current_player_result).to include('Ace', 'You', 'Player 2', 'took')
      end
    end
    context "When the current player's turn changes" do
      it 'current player goes fishing' do
        game.start
        player1.hand = [two_hearts]
        player2.hand = [ace_clubs, king_clubs]
        game.deck.add_card(ace_hearts)
      end
    end
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
  it 'should return false if game has not started' do
    setup_game_with_two_players
    game.start
    expect(game.started?).to be true
  end
  it 'should return true if game has started' do
    setup_game_with_two_players
    expect(game.started?).to be false
  end
end
