require 'sinatra'
require 'sinatra/json'
require 'sinatra/respond_with'
require 'rack/contrib'
require 'securerandom'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/user'

class Server < Sinatra::Base
  enable :sessions
  register Sinatra::RespondWith
  use Rack::JSONBodyParser

  def self.game
    @@game ||= Game.new
  end

  # def reset_state!
  #   @@game = nil
  # end

  get '/' do
    slim :index
  end

  get '/lobby' do
    redirect :game unless self.class.game.empty?    
    respond_to do |f|
      f.json {
        json api_key: session[:current_user].api_key
      }
      f.html { slim :lobby, locals: { game: self.class.game, current_player: session[:current_player] } }
    end
  end

  post '/join' do
    player = create_player
    session[:current_user] = create_user(player)
    respond_to do |f|
      f.json {
        json api_key: session[:current_user].api_key
      }
      f.html { redirect '/lobby' }
    end
  end

  get '/game' do
    # binding.irb
    redirect '/' if self.class.game.nil?
    respond_to do |f|
      f.json {
        return error 401 if session[:current_user].nil?
        json api_key: session[:current_user].api_key
        json players: self.class.game.players
      }
      f.html { slim :game, locals: { game: self.class.game, current_user: session[:current_user] } }
    end
  end

  get '/play' do
    respond_to do |f|
      f.html { slim :game, locals: { play_round: self.class.game.play_round, game: self.class.game, current_user: session[:current_user] } }
    end
  end

  def create_user(player)
    api_key = SecureRandom.urlsafe_base64(24)
    User.new(player, api_key)
  end

  def create_player
    player = Player.new(params['name'])
    self.class.game.add_player(player)
    player
  end

  def auth
    Rack::Auth::Basic::Request.new(request.env)
  end
end
