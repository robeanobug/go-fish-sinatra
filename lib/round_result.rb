class RoundResult
  attr_reader :current_player, :target_player, :fished_card, :taken_cards, :requested_rank, :winners

  def initialize(current_player: nil, target_player: nil, requested_rank: nil, taken_cards: nil, fished_card: nil, winners: nil)
    @current_player = current_player
    @target_player = target_player
    @fished_card = fished_card
    @taken_cards = taken_cards
    @requested_rank = requested_rank
    @winners = winners
  end

  def bystanders_game_response
    return if winners
    "#{current_player.name} asked #{ target_player.name } for any #{ requested_rank }s"
  end

  def bystanders_round_result
    return if winners
    return "Go fish: #{target_player.name} did not have any #{requested_rank}s" if taken_cards.nil?
    if taken_cards.count == 1
      "#{current_player.name} took an #{requested_rank} from #{target_player.name}"
    else
      "#{current_player.name} took #{taken_cards.count} #{requested_rank}s from #{target_player.name}"
    end
  end

  def current_player_action
    return "You are out of cards! You drew a #{fished_card.rank} of #{fished_card.suit}" if fished_card && requested_rank.nil?
    "You drew a #{fished_card.rank} of #{fished_card.suit}" if fished_card
  end

  def winner_output
    return if winners.nil?
    return "The winner is #{winners.first.name}" if winners.count == 1
    "It's a tie. The winners are #{ winners_string }!"

  end

  # def bystanders_played_action
    
  # end

  def current_player_round_result
    return if winners
    return "You took #{ taken_cards_array } from #{ target_player.name }." if taken_cards
    "Go fish! You drew a #{ fished_card.rank } of #{ fished_card.suit }." if fished_card
  end

  private

  def taken_cards_array
    taken_cards&.map { |card| "#{ card.rank } of #{ card.suit }" }
  end

  def winners_string
    winners.map { |winner| winner.name }.join(' and ')
  end
end