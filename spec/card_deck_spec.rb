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
    fit 'should shuffle the deck' do
      unshuffled_deck = deck.cards.dup
      deck.shuffle!
      expect(unshuffled_deck).to match_array deck.cards
      expect(unshuffled_deck).to_not eq deck.cards
    end
  end
end