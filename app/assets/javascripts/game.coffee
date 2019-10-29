class Game
  COLS: ["A", "B", "C", "D", "E", "F", "G", "H"]
  ROWS: [1, 2, 3, 4, 5, 6, 7, 8]

  constructor: ->
    @board = $(".board")
    @cells = @board.find(".board-cell").map (idx, c) => new Cell(c, this)
    @pieces = @board.find(".piece").map (idx, p) => new Piece(p, this)
    @moves = []

  getTurn: ->
    @board.data("current-turn")

  setTurn: (color) ->
    @board.data("current-turn", color)

  getCell: (position) ->
    @cells.filter((idx, c) -> c.position == position )[0]

  getPiece: (position, type=null) ->
    @pieces.filter((idx, p) -> !p.destroyed && p.position == position && (type == null || p.type == type))[0]

  lastMove: ->
    @moves.slice(-1)[0]

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

  isPawnDoubleMove: (move) ->
    # console.log(move)
    true

class Cell
  ATTACKABLE_STATUS: "is-attackable"
  CASTLE_STATUS: "is-castleable"
  MOVABLE_STATUS: "is-movable"
  EN_PASSANT_STATUS: "is-enpassant"

  constructor: (cell, game) ->
    @cell = $(cell)
    @game = game
    @position = @cell.data("position")

    @setEvents()

  setEvents: ->
    @cell.on "click", =>
      piece = @game.getActivePiece()

      if piece != undefined
        if @cell.hasClass(@CASTLE_STATUS)
          piece.castle(this)
        else if @cell.hasClass(@EN_PASSANT_STATUS)
          piece.enPassant(this)
        else if @cell.hasClass(@ATTACKABLE_STATUS) || @cell.hasClass(@MOVABLE_STATUS)
          piece.moveTo(this)

  hasPiece: ->
    @getPiece() != undefined

  getPiece: ->
    @game.getPiece(@position)

  destroyPiece: -> @getPiece().destroy() if @hasPiece()

  isCastleMove: ->
    piece = @game.getActivePiece()
    piece == undefined || piece.castleMoves().indexOf(@position) >= 0

  unhighlight: ->
    @cell.removeClass("#{@ATTACKABLE_STATUS} #{@CASTLE_STATUS} #{@MOVABLE_STATUS} #{@EN_PASSANT_STATUS}")

  highlight: ->
    if @hasPiece()
      @cell.addClass(@ATTACKABLE_STATUS)
    else if @isCastleMove()
      @cell.addClass(@CASTLE_STATUS)
    else if @isEnPassantMove()
      @cell.addClass(@EN_PASSANT_STATUS)
    else
      @cell.addClass(@MOVABLE_STATUS)

  isEnPassantMove: ->
    @game.getActivePiece().enPassantMoves().indexOf(@position) >= 0

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
    cell.destroyPiece()

    @piece.appendTo cell.cell
    @position = cell.position
    @postMove(@position)
    @unhighlightMoves()
    @game.toggleTurn()

  castle: (cell) ->
    rookPos = @changeColumn(cell.position, if cell.position[0] == "G" then 1 else -2)
    rook = @getPiece(rookPos, "rook")

    if rook == undefined
      $.error("no rook found")

    rookNewPos = @changeColumn(cell.position, if cell.position[0] == "G" then -1 else 1)
    rookNewCell = @getCell(rookNewPos)
    rook.moveTo(rookNewCell)
    @moveTo(cell)

  enPassant: (cell) ->
    lastMove = @game.lastMove()
    lastMove.piece.destroy()

    @moveTo(cell)

  destroy: ->
    @destroyed = true
    @piece.detach()

  postMove: (move) ->
    $.ajax
      url: @piece.data("update-path")
      data: {move: move}
      type: "POST"
      dataType: "json"
      headers:
        "X-CSRF-Token" : $("meta[name='csrf-token']").attr("content")

    @moves.push move
    @game.moves.push {piece: this, move: move}

  unhighlightMoves: ->
    for cell in @game.cells
      cell.unhighlight()

  highlightAvailableMoves: ->
    for move in @availableMoves()
      cell = @game.getCell(move)
      cell.highlight() if cell != undefined

  availableMoves: ->
    switch @type
      when "king" then @kingMoves()
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

  castleMoves: ->
    castleMoves = []

    if @type == "king" && !@hasMoved()
      pos = @getPosition(@piece)

      for dir in [1, -1]
        start = 1
        cond = true

        while cond
          cellPos = @changeColumn(pos, start * dir)

          if cellPos != undefined
            piece = @getPiece(cellPos)

            if piece == undefined
              start++
            else if piece.type == "rook" && !piece.hasMoved()
              castleMoves.push @changeColumn(pos, 2 * dir)
              cond = false
            else
              cond = false
          else
            cond = false

    castleMoves

  enPassantMoves: ->
    enPassantMoves = []

    if @type == "pawn"
      lastMove = @game.lastMove()

      if lastMove != undefined && @game.isPawnDoubleMove(lastMove)
        move = [@changeColumn(@position, 1), @changeColumn(@position, -1)].find (m) -> m == undefined || lastMove.move == m

        if move != undefined
          enPassantMoves.push @changeRow(move, if @color == "white" then 1 else -1)

    enPassantMoves


  kingMoves: ->
    pos = @getPosition(@piece)
    available = []

    # diagonal moves
    for vDir in [1, -1]
      for hDir in [1, -1]
        move = @changeAngle(pos, vDir, hDir)
        available.push move if move != undefined && @getFriendly(move) == undefined

    # vertical/horizontal moves
    for type in ["row", "column"]
      for dir in [1, -1]
        move = if type == "row" then @changeRow(pos, dir) else @changeColumn(pos, dir)
        available.push move if move != undefined && @getFriendly(move) == undefined

    # castle moves
    for move in @castleMoves()
      available.push move

    available

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
    verticalMoves.push @changeRow(pos, @setDir(2)) unless @hasMoved()

    for move in verticalMoves
      available.push(move) if move != undefined && @getPiece(move) == undefined

    attackMoves = [@changeAngle(pos, @setDir(1), 1),
                   @changeAngle(pos, @setDir(1), -1)]

    for move in attackMoves
      available.push(move) if move != undefined && @getEnemy(move) != undefined

    for move in @enPassantMoves()
      available.push move

    available

  setDir: (v) ->
    dir = if @color == "white" then 1 else -1
    dir * v

  isMovable: -> @game.getTurn() == @color

  isEnemy: (color) -> @color != color

  hasMoved: -> @moves.length > 0

  getCell: (position) -> @game.getCell(position)

  getPiece: (position, type=null) -> @game.getPiece(position, type)

  getFriendly: (position) ->
    piece = @game.getPiece(position)
    piece = undefined if piece == undefined || piece.isEnemy(@color)
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
