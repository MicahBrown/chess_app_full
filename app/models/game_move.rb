class GameMove < ApplicationRecord
  include TeamEnum

  belongs_to :game
  belongs_to :piece

  validate :is_teams_turn, on: :create

  def is_teams_turn
    errors.add(:team, "can't play") if game.current_turn_color.to_s != team
  end

  after_create :flip_game_turn

  def flip_game_turn
    game.flip_turn!
  end
end
