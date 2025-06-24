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
  end
  fit 'is possible to join a game' do
    visit '/'
    fill_in :name, with: 'John'
    click_on 'Join'
    expect(page).to have_content('Players')
    expect(page).to have_content('John')
  end

  it 'allows multiple players to join game' do
    session1 = Capybara::Session.new(:rack_test, Server.new)
    session2 = Capybara::Session.new(:rack_test, Server.new)
    [ session1, session2 ].each_with_index do |session, index|
      player_name = "Player #{index + 1}"
      session.visit '/'
      session.fill_in :name, with: player_name
      session.click_on 'Join'
      expect(session).to have_content('Players')
      expect(session).to have_css('b', text: player_name)
    end
    expect(session2).to have_content('Player 1')
    session1.driver.refresh
    expect(session1).to have_content('Player 2')
  end

  include Rack::Test::Methods
  def app; Server.new; end
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
    expect(JSON.parse(last_response.body).keys).to include 'players'
  end
end