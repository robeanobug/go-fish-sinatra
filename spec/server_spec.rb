require 'rack/test'
require 'rspec'
require 'spec_helper'
require 'capybara'
require 'capybara/dsl'
ENV['RACK_ENV'] = 'test'
require_relative '../server'

RSpec.describe Server do
  include Capybara::DSL

  before do
    Capybara.app = Server.new
    Capybara.default_driver = :selenium_chrome_headless
    Capybara.server = :puma, { Silent: true }
  end

  after do
    Capybara.reset_sessions!
    Server.reset_state!
  end

  let(:session1) { Capybara::Session.new(:selenium_chrome, Server.new) }
  let(:session2) { Capybara::Session.new(:selenium_chrome, Server.new) }

  def setup_sessions_with_two_players
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join' 
    end
    expect(session1).to have_content("Player 1")
    session1.driver.refresh
  end

  it 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  it 'allows multiple players to join game' do
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
      expect(session).to have_content('Players')
      expect(session).to have_css('li', text: player_name)
    end
    expect(session2).to have_content('Player 1')
    session1.driver.refresh
    expect(session1).to have_content('Player 2')
  end

  describe "plays a round" do
    xit 'displays a round counter that increments one round' do
      setup_sessions_with_two_players
      expect(session1).to have_content("Round count: 0")
      session1.click_on 'Play'
      expect(session1).to have_content("Round count: 1")
    end
    xit 'displays a round counter that increments more than one round' do
      setup_sessions_with_two_players
      expect(session1).to have_content("Round count: 0")
      session1.click_on 'Play'
      session1.click_on 'Play'
      expect(session1).to have_content("Round count: 2")
    end
    it 'displays the round information' do
      setup_sessions_with_two_players
      session1.select 'Aces', from: 'card-rank'
      session1.select 'Player 2', from: 'target-player'
      session1.click_on 'request'
      session2.driver.refresh
      # binding.irb
      game_action = "Player 1 asked Player 2 for any Aces"
      # binding.irb
      expect(session1).to have_content(game_action)
    end
  end

  describe "display hands" do
    it 'displays hands to players' do
      setup_sessions_with_two_players
      card_rank = Server.game.players.first.hand.first.rank
      card_suit = Server.game.players.first.hand.first.suit

      expect(session1).to have_css("img[alt='#{card_rank} of #{card_suit}']")
      expect(session2).to have_no_css("img[alt='#{card_rank} of #{card_suit}']")
    end
  end

  # to do
  # display players hands
  # display the ranks in the current player's hands
  # display the opponents

  include Rack::Test::Methods
  def app; Server.new; end
  describe "POST/join" do
    xit 'returns game status via API' do
      post '/join', { 'name' => 'Caleb' }.to_json, {
        'Accept' => 'application/json',
        'CONTENT_TYPE' => 'application/json'
      }
      api_key = JSON.parse(last_response.body)['api_key']
      expect(api_key).not_to be_nil
      get '/game', nil, {
        'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64(api_key + ':X')}",
        'Accept' => 'application/json'
      }
      expect(JSON.parse(last_response.body).keys).to include 'players'
    end
    
    xit 'does not return the api status without the api key' do
      get '/game', nil, {
        'HTTP_AUTHORIZATION' => "Invalid",
        'Accept' => 'application/json'
      }
      expect(last_response.status).to eq 401
    end
    xit 'does not return the api status if using the wrong api key' do
      post '/join', { 'name' => 'Caleb' }.to_json, {
        'Accept' => 'application/json',
        'CONTENT_TYPE' => 'application/json'
      }

      api_key = JSON.parse(last_response.body)['api_key']

      post '/join', { 'name' => 'Joe' }.to_json, {
        'Accept' => 'application/json',
        'CONTENT_TYPE' => 'application/json'
      }
      get '/game', nil, {
        'HTTP_AUTHORIZATION' => "Basic #{Base64.encode64(api_key + ':X')}",
        'Accept' => 'application/json'
      }
      expect(last_response.status).to eq 401
    end
  end
end
