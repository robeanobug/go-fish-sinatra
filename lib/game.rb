class Game
  attr_accessor :players, :round_count
  REQUIRED_PLAYER_COUNT = 2

  def initialize
    @players = []
    @round_count = 0
  end

  def add_player(player)
    players << player
  end

  def empty?
    players.length < REQUIRED_PLAYER_COUNT
  end

  def play_round
    self.round_count += 1
  end
end
