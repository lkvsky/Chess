class Piece

  attr_accessor :mark, :current_loc, :direction, :until_blocked, :possible_moves, :game, :team

  def initialize(game, team, current_loc=[])
    @current_loc = current_loc
    @game = game
    @team = team
  end

  def all_moves(location)
    if @until_blocked
      find_possible_trail(location)
    else
      find_possible_moves(location)
    end
  end

  def find_possible_moves(current_loc)
    self.direction.map do |coord|
      x = current_loc[0] + coord[0]
      y = current_loc[1] + coord[1]
      [x, y]
    end.select do |pair|
      valid_position?(pair[0], pair[1])
    end
  end

  def find_possible_trail(current_loc)

    every_position_possible = []

    self.direction.each do |path|
      x = current_loc[0] + path[0]
      y = current_loc[1] + path[1]
      next if !valid_position?(x,y)
      # add possible blank spaces
      while @game.gameboard[x][y].nil? do
        every_position_possible << [x,y]
        x, y = x + path[0], y + path[1]
        break if !valid_position?(x,y)
      end
      # add if valid and user can capture a piece
      if valid_position?(x,y) && !@game.gameboard[x][y].nil? && @game.gameboard[x][y].team != @team
        every_position_possible << [x,y] 
      end
    end

    every_position_possible
  end

  def valid_position?(x,y)
    if x >= @game.gameboard.length || x < 0 || y >= @game.gameboard.length || y < 0
      return false
    end
    true
  end
end

class Pawn < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @direction = [[1,0]] : @direction = [[-1,0]]
    @team == 1 ? @mark = "\u2659" : @mark = "\u265F"
    @until_blocked = false
  end
end

class Rook < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @mark = "\u2656" : @mark = "\u265C"
    @direction = [[1,0], [-1,0], [0,-1], [0,1]]
    @until_blocked = true
  end
end

class Knight < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @mark = "\u2658" : @mark = "\u265E"
    @direction = [[-1, 2], [1, 2], [2, -1], [2, 1], [1, -2], [-1, -2], [-2, 1], [-2, -1]]
    @until_blocked = false
  end
end

class Bishop < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @mark = "\u2657" : @mark = "\u265D"
    @direction = [[1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = true
  end
end

class King < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @mark = "\u2654" : @mark = "\u265A"
    @direction = [[1,0], [-1,0], [0,-1], [0,1], [1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = false
  end
end

class Queen < Piece
  def initialize(game, team, current_loc=[])
    super(game, team, current_loc)
    @team == 1 ? @mark = "\u2655" : @mark = "\u265B"
    @direction = [[1,0], [-1,0], [0,-1], [0,1], [1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = true
  end
end