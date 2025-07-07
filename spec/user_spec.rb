require 'spec_helper'
require_relative '../lib/user'
require_relative '../lib/player'
RSpec.describe User do
  let(:player) { Player.new("Player")}
  let(:user) { User.new(player, "key") }
  it "has a player and an api_key" do
    expect(user.player).to be_a(Player)
    expect(user.api_key).to eq("key")
  end
  it 'has a name' do
    expect(user.name).to be_a(String)
  end
end