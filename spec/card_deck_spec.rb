require_relative "../lib/card_deck"
require "spec_helper"

RSpec.describe CardDeck do
  let(:deck) { CardDeck.new }
  it 'holds playing cards' do
    expect(deck.cards.first).to be_a(PlayingCard)
  end
  it 'has a specified deck length' do
    expect(deck.cards.length).to eq CardDeck::DECK_COUNT
  end
  it 'deals a card' do
    expect(deck.deal_card).to be_a(PlayingCard)
  end
  it 'adds a card' do
    deck.add_card(PlayingCard.new("Ace", "Clubs"))
    card = deck.deal_card
    expect(card.rank).to eq "Ace"
    expect(card.suit).to eq "Clubs"
  end
  describe '#shuffle!' do
    it 'should shuffle the deck' do
      unshuffled_deck = deck.cards.dup
      deck.shuffle!
      expect(unshuffled_deck).to match_array deck.cards
      expect(unshuffled_deck).to_not eq deck.cards
    end
  end
  describe "#empty?" do
    it 'returns true if empty' do
      deck.cards = []
      expect(deck.empty?).to be true
    end
    it 'returns false if it has cards' do
      deck.cards = ["cards", "cards", "cards"]
      expect(deck.empty?).to be false
    end
  end
  describe "attributes" do
    it 'should have cards' do
      expect(deck.attributes).to include("cards")
    end
  end
end