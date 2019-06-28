require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "creating game with pieces" do
    it "" do
      game = FactoryBot.build :game

      expect {
        game.create_with_pieces!
      }.to change(game.pieces, :count).by 32
    end
  end
end
