class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.new

    if game.save
      redirect_to game_path(game), notice: "Successfully started new game!"
    else
      redirect_to games_path, alert: "Unable to start new game."
    end
  end

  def show
  end
end
