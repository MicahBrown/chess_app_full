class GameMovesController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    piece = game.pieces.find(params[:piece_id])
    piece.move!(params[:move])

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
