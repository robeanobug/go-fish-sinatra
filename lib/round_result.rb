class RoundResult
  attr_reader :current_player, :target_player, :fished_card, :taken_cards, :requested_rank

  def initialize(current_player:, target_player:, requested_rank:, taken_cards: nil, fished_card: nil)
    @current_player = current_player
    @target_player = target_player
    @fished_card = fished_card
    @taken_cards = taken_cards
    @requested_rank = requested_rank
  end

  def bystanders_game_response
    "#{current_player.name} asked #{ target_player.name } for any #{ requested_rank }s."
  end

  def bystanders_round_result
    return "Go fish. #{target_player.name} did not have any #{requested_rank}s." if taken_cards.nil?
    if taken_cards.count == 1
      "#{current_player.name} took an #{requested_rank} from #{target_player.name}."
    else
      "#{current_player.name} took #{taken_cards.count} #{requested_rank}s from #{target_player.name}."
    end
  end

  # def bystanders_played_action
    
  # end

  def current_player_result
    return "You took #{ taken_cards_array } from #{ target_player.name }." if taken_cards
    # "Go fish! You drew a #{ fished_card.rank } of #{ fished_card.suit }." if fished_card
  end

  private

  def taken_cards_array
    taken_cards&.map { |card| "#{ card.rank } of #{ card.suit }" }
  end
end