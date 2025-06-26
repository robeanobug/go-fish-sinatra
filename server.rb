require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'
require 'securerandom'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/user'
require_relative 'lib/card_deck'

class Server < Sinatra::Base
  enable :sessions
  register Sinatra::RespondWith
  use Rack::JSONBodyParser

  def self.game
    @@game ||= Game.new
  end

  def self.reset_state!
    @@game = nil
  end

  get '/' do
    slim :index
  end

  # get '/lobby' do
  #   redirect :game unless self.class.game.empty?    
  #   respond_to do |f|
  #     f.json {
  #       json api_key: session[:current_user].api_key
  #     }
  #     f.html { slim :lobby, locals: { game: self.class.game, current_user: session[:current_user] } }
  #   end
  # end

  post '/join' do
    player = create_player
    session[:current_user] = create_user(player)
    respond_to do |f|
      f.json { json api_key: session[:current_user].api_key }
      f.html { redirect '/game' }
    end
  end

  get '/game' do
    redirect '/' if self.class.game.nil?
    self.class.game.start if !self.class.game.started? && self.class.game.enough_players?
    respond_to do |f|
      f.json do
        return error 401 if session[:current_user].nil?
        json api_key: session[:current_user].api_key
        json players: self.class.game.players
      end
      f.html { slim :game, locals: { game: self.class.game, current_player: find_player(session[:current_user]) } }
    end
  end

  post '/play' do
    self.class.game.play_round
    respond_to do |f|
      f.html { redirect "/game" }
    end
  end

  def create_user(player)
    api_key = SecureRandom.urlsafe_base64(24)
    user = User.new(player, api_key)
    user
  end

  def create_player
    player = Player.new(params['name'])
    self.class.game.add_player(player)
    player
  end

  def find_player(user)
    self.class.game.players.find do |player|
      player.name == user.player.name
    end
  end

  def auth
    Rack::Auth::Basic::Request.new(request.env)
  end

  def session_key
    return session[:api_key] unless request.content_type == 'application/json'
    auth.username
  end
end
