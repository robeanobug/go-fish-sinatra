class Game
  attr_accessor :players
  REQUIRED_PLAYER_COUNT = 2

  def initialize
    @players = []
  end

  def add_player(player)
    players << player
  end

  def empty?
    players.length < REQUIRED_PLAYER_COUNT
  end
end
