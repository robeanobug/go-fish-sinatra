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
end