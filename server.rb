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

  post '/join' do
    player = create_player
    session[:current_user] = create_user(player)
    respond_to do |f|
      f.json do
        json api_key: session[:current_user].api_key
      end
      f.html do
        redirect "/game"
        slim :game, locals: { game: self.class.game, current_player: find_player_from_user(session[:current_user]) }
      end
    end
  end

  get '/game' do
    redirect '/' if self.class.game.nil?
    self.class.game.start if !self.class.game.started? && self.class.game.enough_players?
    respond_to do |f|
      f.json do
        return error 401 if session[:current_user].nil?
        json api_key: session[:current_user].api_key
        json self.class.game.attributes(session[:current_user].name)
      end
      f.html { slim :game, locals: { game: self.class.game, current_player: find_player_from_user(session[:current_user]) } }
    end
  end

  post '/play' do
    target_player_name = params['target-player']
    target_player = find_player_from_name(target_player_name)
    requested_rank = params['card-rank']&.chop
    self.class.game.play_round(requested_rank, target_player)
    respond_to do |f|
      f.html do
        redirect "/game"
      end
    end
  end

  def create_user(player)
    api_key = SecureRandom.urlsafe_base64(24)
    user = User.new(player, api_key)
    user
  end

  def create_player
    player = Player.new(params['name'])
    player_count = params[:player_count]
    self.class.game.player_count = player_count.to_i if player_count
    self.class.game.add_player(player)
    player
  end

  def find_player_from_user(user)
    # binding.irb
    players.find { |player| player.name == user.name } 
  end

  def find_player_from_name(name)
    players.find { |player| player.name == name } 
  end

  def players
    self.class.game.players
  end
  
  def game
    self.class.game
  end

  def auth
    Rack::Auth::Basic::Request.new(request.env)
  end

  def session_key
    return session[:api_key] unless request.content_type == 'application/json'
    auth.username
  end
end
