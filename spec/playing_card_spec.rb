require 'spec_helper'
require_relative '../lib/playing_card'

RSpec.describe PlayingCard do
  let(:playing_card) { PlayingCard.new('Two', 'Spades')}
  it 'has a rank and a suit' do
    expect(playing_card.rank).to eq('Two')
    expect(playing_card.suit).to eq('Spades')
  end
  it 'has attributes rank and suit' do
    expect(playing_card.attributes).to include("rank", "suit")
  end
end