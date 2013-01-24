class Piece

  attr_accessor :mark, :direction, :until_blocked, :game, :team

  def initialize(game, team)
    @game = game
    @team = team
  end

  def all_moves(location)
    if self.class == Pawn
      return pawn_moves(location)
    elsif @until_blocked
      return find_possible_trail(location)
    else
      find_possible_moves(location)
    end
  end

  # private

  def find_possible_moves(current_loc)
    board = @game.gameboard
    direction = self.direction

    possibles = direction.map do |coord|
      x, y = (current_loc[0] + coord[0]), (current_loc[1] + coord[1])
      [x, y]
    end.select do |pair|
      valid_position?(pair[0], pair[1])
    end
  end

  def find_possible_trail(current_loc)
    board = @game.gameboard
    every_position_possible = []

    self.direction.each do |path|
      x, y = (current_loc[0] + path[0]), (current_loc[1] + path[1])
      next if !valid_position?(x, y)

      while board[x][y].nil? do
        every_position_possible << [x,y]
        x, y = (x + path[0]), (y + path[1])
        break if !valid_position?(x, y)
      end

      if valid_position?(x,y) && !board[x][y].nil? && board[x][y].team != @team
        every_position_possible << [x,y] 
      end
    end

    every_position_possible
  end

  def pawn_moves(current_loc)
    direction = []
    direction += self.direction
    board = @game.gameboard

    if self.first_move
      self.direction.map do |coord|
        x, y = (coord[0] * 2), coord[1]
        direction << [x, y]
      end

      self.first_move = false
    end

    possibles = direction.map do |coord|
      x, y = current_loc[0] + coord[0], current_loc[1] + coord[1]
      [x, y]
    end.select do |pair|
      valid_position?(pair[0], pair[1]) && board[pair[0]][pair[1]].nil?
    end

    return possibles if pawn_kills(current_loc).nil?
    possibles + pawn_kills(current_loc)
  end

  def pawn_kills(current_loc)
    board = @game.gameboard
    kills = []

    self.direction.map do |coord|
      x, y = (coord[0] + current_loc[0]), (coord[1] + current_loc[1] + 1)
      kills << [x, y]
    end
    self.direction.map do |coord|
      x, y = (coord[0] + current_loc[0]), (coord[1] + current_loc[1] - 1)
      kills << [x, y]
    end

    kills.select { |pair| !board[pair[0]][pair[1]].nil? }
  end

  def valid_position?(x,y)
    board = @game.gameboard
    x < board.length && x >= 0 && y < board.length && y >= 0
  end
end

class Pawn < Piece
  attr_accessor :first_move

  def initialize(game, team)
    super(game, team)
    @first_move = true
    @team == 1 ? @direction = [[1, 0]] : @direction = [[-1, 0]]
    @team == 1 ? @mark = "\u2659" : @mark = "\u265F"
    @until_blocked = false
  end
end

class Rook < Piece
  def initialize(game, team)
    super(game, team)
    @team == 1 ? @mark = "\u2656" : @mark = "\u265C"
    @direction = [[1, 0], [-1, 0], [0, -1], [0, 1]]
    @until_blocked = true
  end
end

class Knight < Piece
  def initialize(game, team)
    super(game, team)
    @team == 1 ? @mark = "\u2658" : @mark = "\u265E"
    @direction = [[-1, 2], [1, 2], [2, -1], [2, 1], [1, -2], [-1, -2], [-2, 1], [-2, -1]]
    @until_blocked = false
  end
end

class Bishop < Piece
  def initialize(game, team)
    super(game, team)
    @team == 1 ? @mark = "\u2657" : @mark = "\u265D"
    @direction = [[1 ,1], [-1, -1], [1, -1], [-1, 1]]
    @until_blocked = true
  end
end

class King < Piece
  def initialize(game, team)
    super(game, team)
    @team == 1 ? @mark = "\u2654" : @mark = "\u265A"
    @direction = [[1, 0], [-1, 0], [0, -1], [0, 1], [1, 1], [-1, -1], [1, -1], [-1, 1]]
    @until_blocked = false
  end
end

class Queen < Piece
  def initialize(game, team)
    super(game, team)
    @team == 1 ? @mark = "\u2655" : @mark = "\u265B"
    @direction = [[1, 0], [-1, 0], [0, -1], [0, 1], [1, 1], [-1, -1], [1,- 1], [-1, 1]]
    @until_blocked = true
  end
end