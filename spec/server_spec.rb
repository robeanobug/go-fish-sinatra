require 'rack/test'
require 'rspec'
require 'spec_helper'
require 'capybara'
require 'capybara/dsl'
ENV['RACK_ENV'] = 'test'
require_relative '../server'
require_relative '../lib/playing_card'

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
  let(:session3) { Capybara::Session.new(:selenium_chrome, Server.new) }

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

  def setup_sessions_with_three_players
    [ session1, session2, session3 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.choose 'three' if index == 0
      session.click_on 'Join' 
    end
    expect(session1).to have_content("Player 1")
    session1.driver.refresh
  end

  def deal_unshuffled_cards
    clear_books_and_hands
    unshuffle_deck
    redeal_cards
    session1.driver.refresh
    session2.driver.refresh
  end

  def unshuffle_deck
    Server.game.deck = CardDeck.new
  end

  def redeal_cards
    Server.game.deal_cards
  end

  def clear_books_and_hands
    Server.game.players.each do |player|
      player.books = []
      player.hand = []
    end
  end

  it 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  it 'allows multiple players to join game' do
    setup_sessions_with_two_players

    expect(session2).to have_content('Player 1')
    session1.driver.refresh
    expect(session1).to have_content('Player 2')
  end

  describe "plays a round" do
    context 'when the current player gets the cards from target' do
      before do
        setup_sessions_with_two_players
        deal_unshuffled_cards
        session1.select 'Aces', from: 'card-rank'
        session1.select 'Player 2', from: 'target-player'
        session1.click_on 'request'
        session2.driver.refresh
      end
      it 'displays the game response' do
        game_action = "Player 1 asked Player 2 for any Aces"
        expect(session1).to have_content(game_action)
      end
      it 'displays the game round result' do
        game_round_result = "Player 1 took 2 Aces from Player 2"
        expect(session1).to have_content(game_round_result)
      end
      it 'does not display the player action if there is not a player action' do
        expect(session1).to have_no_css(".feed__bubble--player-action")
      end
    end

    context 'when the current player goes fishing' do
      before do
        setup_sessions_with_two_players
        deal_unshuffled_cards
        Server.game.current_player.hand = [PlayingCard.new('Two', 'Hearts')]
        Server.game.players.last.hand = [PlayingCard.new('Ace', 'Hearts')]
        session1.driver.refresh
        session1.select 'Twos', from: 'card-rank'
        session1.select 'Player 2', from: 'target-player'
        session1.click_on 'request'
        session2.driver.refresh
      end
      it 'displays the player action if there is a player action to the current player but not other players' do
        personalized_player_action = "You drew a"
        player_action = "#{Server.game.players.first.name} drew a card"
        expect(session1).to have_content(personalized_player_action)
        expect(session2).to have_no_content(personalized_player_action)
        expect(session2).to have_content(player_action)
      end
      it 'should display the next player name' do
        expect(session1).to have_content("#{Server.game.players.last.name}'s Turn")
      end
    end

    context "When it is not your turn" do
      before do
        setup_sessions_with_two_players
      end
      it 'should have disabled buttons' do
        expect(session1).to have_no_css(".btn--disabled")
        expect(session2).to have_css(".btn--disabled")
      end
      it 'should have disabled form inputs' do
        expect(session1).to_not have_selector(:field, 'card-rank', readonly: true)
        expect(session1).to_not have_selector(:field, 'target-player', readonly: true)
        expect(session2).to have_selector(:field, 'card-rank', readonly: true)
        expect(session2).to have_selector(:field, 'target-player', readonly: true)
      end
    end

    context "When a player creates a book" do
      before do
        setup_sessions_with_two_players
        deal_unshuffled_cards
        session1.select 'Aces', from: 'card-rank'
        session1.select 'Player 2', from: 'target-player'
        session1.click_on 'request'
        session2.driver.refresh
      end
      it 'should display the book' do
        book_card = Server.game.current_player.books.first.first
        card_rank = book_card.rank
        session1.within ".playing-cards--books" do
          expect(session1).to have_css("img[alt='Book of #{card_rank}s']")
        end
      end
    end

    context "When a player has no cards because their cards were put into books" do
      before do
        setup_sessions_with_two_players
        deal_unshuffled_cards
      end
      it 'should draw a card for current player' do
        8.times do 
          session1.click_on 'request'
          expect(session1).to have_content("Ace")
        end
        expect(session1).to have_content("out of cards")
      end
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
  describe 'display player content' do
    it 'has an accordion' do
      setup_sessions_with_two_players
      expect(session1).to have_css(".accordion")
    end
    it 'shows the player name' do
      setup_sessions_with_two_players
      current_player_name = Server.game.players.first.name
      opponent_name = Server.game.players.last.name
      session1.within ".players-content" do
        expect(session1).to have_content(opponent_name)
        expect(session1).to have_no_content(current_player_name)
      end
    end
    it 'shows the player card count and books count' do
      setup_sessions_with_two_players
      opponent = Server.game.players.last
      session1.within ".players-content" do
        expect(session1).to have_content(opponent.hand.count)
        expect(session1).to have_content(opponent.books.count)
      end
    end
  end

  context "when there is a winner" do
    before do
      setup_sessions_with_two_players
      deal_unshuffled_cards
    end
    xit 'should declare a winner' do
      loop do
        sleep(0.5)
        session1.click_on 'request'
        break if Server.game.over?
      end
      expect(session1).to have_content("winner")
    end
  end

  context "when there are three players" do
    before do
      setup_sessions_with_three_players
      session1.driver.refresh
      session2.driver.refresh
      session3.driver.refresh
    end
    it 'goes to game screen' do
      expect(session1).to have_content(Server.game.players[1].name)
      expect(session1).to have_content(Server.game.players[2].name)
      expect(Server.game.players.last.hand.count).to eq Game::BASE_HAND_SIZE
    end
    it 'should play a round when the current player presses request' do
      session1.click_on "request"
      session2.driver.refresh
      session3.driver.refresh
      expect(session1).to have_content("ask")
      expect(session2).to have_content("ask")
      expect(session3).to have_content("ask")
    end
  end

  context "when there are five players" do
    
  end

  include Rack::Test::Methods
  def app; Server.new; end
  describe "POST/join" do
    it 'returns game status via API' do
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
      
      # expect(JSON.parse(last_response.body).keys).to include 'players'
      # p last_response
      expect(last_response).to match_json_schema('game')
    end
    
    it 'does not return the api status without the api key' do
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