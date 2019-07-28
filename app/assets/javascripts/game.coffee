class Game
  COLS: ["A", "B", "C", "D", "E", "F", "G", "H"]
  ROWS: [1, 2, 3, 4, 5, 6, 7, 8]

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
    @pieces.filter((idx, p) -> !p.destroyed && p.position == position )[0]

  validPosition: (position) ->
    position.length == 2 &&
    @ROWS.indexOf(parseInt(position.match(/\d+/)[0])) >= 0 &&
    @COLS.indexOf(position.match(/[A-H]/)[0]) >= 0

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
      @activate() if @isMovable()

  deactivate: ->
    @unhighlightMoves()
    @active = false

  activate: ->
    console.log("activated: #{@color} #{@type}")
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
      when "queen" then @queenMoves()
      when "bishop" then @bishopMoves()
      when "knight" then @knightMoves()
      when "rook" then @rookMoves()
      when "pawn" then @pawnMoves()

  changeColumn: (pos, num, validate = true) ->
    rows = @game.COLS
    pos = pos.replace(/[A-H]/, ((v) -> rows[(rows.indexOf(v)) + num] ))
    pos = undefined if validate && !@game.validPosition(pos)
    pos

  changeRow: (pos, num, validate = true) ->
    pos = pos.replace(/\d/, ((v) -> parseInt(v) + num ))
    pos = undefined if validate && !@game.validPosition(pos)
    pos

  changeAngle: (pos, v, h) ->
    pos = @changeRow(pos, v, false)
    pos = @changeColumn(pos, h, false)
    pos = undefined unless @game.validPosition(pos)
    pos

  queenMoves: ->
    @bishopMoves().concat @rookMoves()

  bishopMoves: ->
    pos = @getPosition(@piece)
    available = []

    for vDir in [1, -1]
      for hDir in [1, -1]
        start = 1
        cond = true

        while cond
          move = @changeAngle(pos, vDir * start, hDir * start)

          if move != undefined
            piece = @getPiece(move)

            if piece == undefined
              available.push move
              start++
            else if piece.isEnemy(@color)
              available.push move
              cond = false
            else
              cond = false
          else
            cond = false

    available

  knightMoves: ->
    pos = @getPosition(@piece)
    available = []

    for hDir in [1, -1]
      for vDir in [1, -1]
        move1 = @changeRow(pos, hDir * 2)
        move1 = @changeColumn(move1, vDir) if move1 != undefined
        available.push move1 if move1 != undefined

        move2 = @changeColumn(pos, hDir * 2)
        move2 = @changeRow(move2, vDir) if move2 != undefined
        available.push move2 if move2 != undefined

    available.filter (move) => @getFriendly(move) == undefined

  rookMoves: ->
    pos = @getPosition(@piece)
    available = []

    for type in ["row", "column"]
      for dir in [1, -1]
        start = 1
        cond = true

        while cond
          move = if type == "row" then @changeRow(pos, dir * start) else @changeColumn(pos, dir * start)

          if move != undefined
            piece = @getPiece(move)

            if piece == undefined
              available.push move
              start++
            else if piece.isEnemy(@color)
              available.push move
              cond = false
            else
              cond = false
          else
            cond = false

    available

  pawnMoves: ->
    pos = @getPosition(@piece)
    available = []

    verticalMoves = [@changeRow(pos, @setDir(1))]
    verticalMoves.push @changeRow(pos, @setDir(2)) if @moves.length == 0

    for move in verticalMoves
      available.push(move) if move != undefined && @getPiece(move) == undefined

    attackMoves = [@changeAngle(pos, @setDir(1), 1),
                   @changeAngle(pos, @setDir(1), -1)]

    for move in attackMoves
      available.push(move) if move != undefined && @getEnemy(move) != undefined

    available

  setDir: (v) ->
    dir = if @color == "white" then 1 else -1
    dir * v

  isMovable: -> @game.getTurn() == @color

  isEnemy: (color) -> @color != color

  getPiece: (position) ->
    @game.getPiece(position)

  getFriendly: (position) ->
    piece = @game.getPiece(position)
    piece = undefined if piece == undefined || piece.isEnemy(@color)
    console.log(piece)
    piece

  getEnemy: (position) ->
    piece = @game.getPiece(position)
    piece = undefined if piece == undefined || !piece.isEnemy(@color)
    piece

  getPosition: (piece) ->
    cell = piece.parent(".board-cell")
    cell.data("position")


$(document).ready ->
  new Game()
