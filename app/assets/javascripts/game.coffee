class Game
  constructor: () ->
    @board = $(".board")
    @turn = @board.data("current-turn")

$(document).ready ->
  new Game()
