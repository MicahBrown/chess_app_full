class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.new

    if game.create_with_pieces!
      redirect_to game_path(game), notice: "Successfully started new game!"
    else
      redirect_to games_path, alert: "Unable to start new game."
    end
  end

  def show
    @game = Game.find(params[:id])
  end
end
