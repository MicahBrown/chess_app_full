class Game
  ROWS: ["A", "B", "C", "D", "E", "F", "G", "H"]
  COLS: [1, 2, 3, 4, 5, 6, 7, 8]

  constructor: ->
    @board = $(".board")
    @cells = @board.find(".board-cell").map (idx, c) => new Cell(c, this)
    @pieces = @board.find(".piece").map (idx, p) => new Piece(p, this)

  getTurn: ->
    @board.data("current-turn")

  setTurn: (color) ->
    @board.data("current-turn", color)

  getCell: (position) ->
    @cells.filter((idx, c) -> c.position == position )[0]

  getPiece: (position) ->
    @pieces.filter((idx, p) -> p.position == position )[0]

  toggleTurn: ->
    color = if @getTurn() == "white" then "black" else "white"
    @setTurn color

  getActivePiece: ->
    @pieces.filter((idx, p) -> p.active )[0]

  deactivateActivePiece: ->
    piece = @getActivePiece()
    piece.deactivate() if piece != undefined

class Cell
  ATTACKABLE_STATUS: "is-attackable"
  MOVABLE_CLASS: "is-movable"

  constructor: (cell, game) ->
    @cell = $(cell)
    @game = game
    @position = @cell.data("position")

    @setEvents()

  setEvents: ->
    @cell.on "click", =>
      if @cell.hasClass(@ATTACKABLE_STATUS) || @cell.hasClass(@MOVABLE_CLASS)
        piece = @game.getActivePiece()
        piece.moveTo(this) if piece != undefined

  hasPiece: ->
    @getPiece() != undefined

  getPiece: ->
    @game.getPiece(@position)

  unhighlight: ->
    @cell.removeClass("#{@ATTACKABLE_STATUS} #{@MOVABLE_CLASS}")

  highlight: ->
    if @hasPiece()
      console.log(@getPiece())
      @cell.addClass(@ATTACKABLE_STATUS)
    else
      @cell.addClass(@MOVABLE_CLASS)

class Piece
  constructor: (piece, game) ->
    @piece = $(piece)
    @game = game

    @type = @piece.data("type")
    @color = @piece.data("color")
    @position = @getPosition(@piece)
    @moves = []
    @active = false
    @destroyed = false

    @setEvents()

  setEvents: ->
    @piece.on "click", =>
      @activate() if @canMove()

  canMove: ->
    @game.getTurn() == @color

  deactivate: ->
    @unhighlightMoves()
    @active = false

  activate: ->
    @game.deactivateActivePiece()
    @active = true
    @highlightAvailableMoves()

  moveTo: (cell) ->
    if cell.hasPiece()
      cell.getPiece().destroy()

    @piece.appendTo cell.cell

    @position = @getPosition(@piece)
    @moves.push cell.position
    @unhighlightMoves()
    @game.toggleTurn()

  destroy: ->
    @destroyed = true
    @piece.detach()

  unhighlightMoves: ->
    for cell in @game.cells
      cell.unhighlight()

  highlightAvailableMoves: ->
    for move in @availableMoves()
      cell = @game.getCell(move)
      cell.highlight() if cell != undefined

  availableMoves: ->
    switch @type
      when "king" then "im a king"
      when "queen" then "im a queen"
      when "bishop" then "im a bishop"
      when "knight" then "im a knight"
      when "rook" then "im a rook"
      when "pawn" then @pawnMoves()

  changeColumn: (pos, num) ->
    pos.replace(/\d/, ((v) -> parseInt(v) + num ))

  changeRow: (pos, num) ->
    rows = @game.ROWS
    pos.replace(/[A-H]/, ((v) -> rows[(rows.indexOf(v)) + num] ))

  changeAngle: (pos, v, h) ->
    pos = @changeRow(pos, v)
    pos = @changeColumn(pos, h)
    pos

  pawnMoves: ->
    pos = @getPosition(@piece)
    available = []

    verticalMoves = [@changeColumn(pos, if @color == "white" then 1 else -1)]
    verticalMoves.push @changeColumn(pos, if @color == "white" then 2 else -2) if @moves.length == 0

    for move in verticalMoves
      available.push(move) unless @game.getPiece(move)

    attackMoves = [@changeAngle(pos, 1, if @color == "white" then 1 else -1),
                   @changeAngle(pos, -1, if @color == "white" then 1 else -1)]

    for move in attackMoves
      available.push(move) if @game.getPiece(move)

    available

  getPosition: (piece) ->
    cell = piece.parent(".board-cell")
    cell.data("position")


$(document).ready ->
  new Game()
