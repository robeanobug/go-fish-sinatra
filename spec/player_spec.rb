require_relative "../lib/player"
require "spec_helper"

RSpec.describe Player do
  let(:player) { Player.new("Player")}
  let(:ace_clubs) {PlayingCard.new('Ace', 'Clubs') }
  let(:ace_hearts) {PlayingCard.new('Ace', 'Hearts') }
  let(:ace_spades) {PlayingCard.new('Ace', 'Spades') }
  let(:ace_diamonds) {PlayingCard.new('Ace', 'Diamonds') }

  it 'has a name' do
    expect(player.name).to eq("Player")
  end
  it 'has a hand' do
    expect(player.hand).to be_a(Array)
  end
  it 'has books' do
    expect(player.books).to be_a(Array)
  end
  it 'adds cards to the hand' do
    player.add_cards([ace_clubs, ace_hearts])
    expect(player.hand).to eq([ace_clubs, ace_hearts])
  end
  it 'will create a book if possible if multiple cards are added' do
    player.hand = [ace_clubs, ace_hearts]
    player.add_cards([ace_diamonds, ace_spades])
    expect(player.books.flatten).to include(ace_clubs, ace_hearts, ace_diamonds, ace_spades)
    expect(player.books.length).to eq 1
  end
  it 'will create a book if possible if only a playing card is added to the hand' do
    player.hand = [ace_clubs, ace_hearts, ace_diamonds]
    player.add_cards(ace_spades)
    expect(player.books.flatten).to include(ace_clubs, ace_hearts, ace_diamonds, ace_spades)
    expect(player.books.length).to eq 1
  end
  it 'removes cards from hand' do
    player.hand = [ace_clubs, ace_hearts]
    player.remove_cards([ace_clubs, ace_hearts])
    expect(player.hand).to eq([])
  end
  it 'returns true if player is out of cards' do
    player.hand = []
    expect(player.out_of_cards?).to be true
  end
  describe '#ranks' do
    it 'should tell what ranks are in the player hand' do
      player.add_cards([ace_clubs, ace_hearts])
      expect(player.ranks).to eq(['Aces'])
    end
    it 'should return [] if player has no cards' do
      player.hand = []
      expect(player.ranks).to eq []
    end
  end

  describe "#attributes" do
    it 'should have a name hand and books' do
      expect(player.attributes).to include("name", "books")
    end
  end

  it 'should display the hand' do
    player.hand = [ace_hearts]
    expect(player.display_hand).to eq(["Ace of Hearts"])
  end
end