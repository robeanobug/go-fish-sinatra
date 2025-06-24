require_relative "../lib/player"
require "spec_helper"

RSpec.describe Player do
  let(:player) { Player.new("Player")}

  it 'has a name' do
    expect(player.name).to eq("Player")
  end
end