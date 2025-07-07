class User
  attr_reader :player, :api_key
  def initialize(player, api_key)
    @player = player
    @api_key = api_key
  end
  def name
    player.name
  end
end