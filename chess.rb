require 'yaml'
require 'debugger'

class Game

  attr_accessor :gameboard

  def initialize
  end

  def create_gameboard
    @gameboard = Array.new(8){Array.new(8)}
    create_pawns
    create_backrow
  end

  def save_game(filename)
    game = File.open(filename, "w")
    game.write(self.to_yaml)
    game.close
  end

  def create_pawns
    8.times do |i|
      @gameboard[1] << Pawn.new(self, 1, [1,i])
      @gameboard[1].shift
    end
    8.times do |i|
      @gameboard[6] << Pawn.new(self, 2, [6,i])
      @gameboard[6].shift
    end
  end

  def create_backrow
    white = [Rook.new(self, 1), Knight.new(self, 1), Bishop.new(self, 1), Queen.new(self, 1),
              King.new(self, 1), Bishop.new(self, 1), Knight.new(self, 1), Rook.new(self, 1)]
    black = [Rook.new(self, 2), Knight.new(self, 2), Bishop.new(self, 2), King.new(self, 2),
              Queen.new(self, 2), Bishop.new(self, 2), Knight.new(self, 2), Rook.new(self, 2)]
    white.each_with_index do |piece, i|
      piece.current_loc = [0,i]
      @gameboard[0] << piece
      @gameboard[0].shift
    end
    black.each_with_index do |piece, i|
      piece.current_loc = [8,i]
      @gameboard[7] << piece
      @gameboard[7].shift
    end
  end

  def print_gameboard
    puts "     A  B  C  D  E  F  G  H "
    puts "     -  -  -  -  -  -  -  - "
    @gameboard.each_with_index do |row, i|
      print " #{i} |"
      row.each do |square|
        if square.nil?
          print " \u25A1 "
        else
          print " #{square.mark} "
        end
      end
      puts "\n"
    end
  end

  def play
    user_settings
    create_gameboard
    print_gameboard
    while true
      puts "Player 1's turn"
      @player1.make_move
      print_gameboard
      puts "Player 2's turn"
      @player2.make_move
      print_gameboard
      false
    end
  end


  def user_settings
    @player1, @player2 = HumanPlayer.new(1, self), HumanPlayer.new(2, self)
  end
end


class HumanPlayer

  POSITION_MAPPING = {"A" => 0,
                      "B" => 1,
                      "C" => 2,
                      "D" => 3,
                      "E" => 4,
                      "F" => 5,
                      "G" => 6,
                      "H" => 7}
  attr_accessor :team, :current_game, :captured

  def initialize(team, game)
    @team = team
    @game = game
    @captured = []
  end

  def get_input
    while true
      puts "Where do you want to go (ex: A6, B7)"
      input = gets.chomp
      if input.include?(",")
        return input
      else
        puts "Invalid input"
      end
    end
  end

  def process_input
    input = get_input.split(", ").map! { |pair| pair.split("") }
    x2 = POSITION_MAPPING[(input[0][0].upcase)]
    y2 = POSITION_MAPPING[(input[1][0].upcase)]
    x1 = input[0][1].to_i
    y1 = input[1][1].to_i
    [[x1, x2], [y1, y2]]
  end

  def make_move
    while true
      input = process_input
      if valid_move?(input)
        move_piece(input)
        return
      end
      false
    end
  end

  def valid_move?(input)
    start, target = input[0], input[1]
    possible_moves = []

    if @game.gameboard[start[0]][start[1]].until_blocked
      possible_moves = @game.gameboard[start[0]][start[1]].find_possible_trail(start)
    else
      possible_moves = @game.gameboard[start[0]][start[1]].find_possible_moves(start)
    end

    if @game.gameboard[start[0]][start[1]].nil?
      puts "Not a valid move, this space is empty"
      return false
    end

    if @game.gameboard[start[0]][start[1]].team != @team
      puts "This is not your piece"
      return false
    end

    unless @game.gameboard[target[0]][target[1]].nil?
      unless @game.gameboard[start[0]][start[1]].kill?(target)
        puts "Your piece is there"
        return false
      end
    end

    unless possible_moves.include?(target)
      puts "Not inside possible moves"
      return false
    end

    true
  end

  def move_piece(input)
    start = input[0]
    target = input[1]
    if !@game.gameboard[start[0]][start[1]].kill?(target)
      @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
    else
      @captured << @game.gameboard[target[0]][target[1]]
      @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
    end
  end

end

class Piece

  attr_accessor :mark, :current_loc, :direction, :until_blocked, :possible_moves, :game, :team

  def initialize(game, team, current_loc=[])
    @current_loc = current_loc
    @game = game
    @team = team
  end

  def find_possible_moves(current_loc)
    self.direction.map do |coord|
      x = current_loc[0] + coord[0]
      y = current_loc[1] + coord[1]
      [x, y]
    end.select do |pair|
      (pair[0] >= 0) && (pair[0] < @game.gameboard.length) && (pair[1] >= 0) && (pair[1] < @game.gameboard.length)
    end
  end

  def find_possible_trail(current_loc)
    every_position_possible = []
    #debugger
    self.direction.each do |path|
      x = current_loc[0] + path[0]
      y = current_loc[1] + path[1]
      next if !valid_position?(x,y)

      while @game.gameboard[x][y].nil? do
        every_position_possible << [x,y]
        x, y = x + path[0], y + path[1]
        break if !valid_position?(x,y)
      end
      if valid_position?(x,y) && !@game.gameboard[x][y].nil? && @game.gameboard[x][y].team != @team
        every_position_possible << [x,y] 
      end

    end
    every_position_possible.select! do |pair|
      (pair[0] >= 0) && (pair[0] < @game.gameboard.length) && (pair[1] >= 0) && (pair[1] < @game.gameboard.length)
    end

    every_position_possible
  end

  def valid_position?(x,y)
    if x >= @game.gameboard.length || x < 0 || y >= @game.gameboard.length || y < 0
      return false
    end
    true
  end

  def kill?(target)
    unless self.nil? || @game.gameboard[target[0]][target[1]].nil?
      return true if @game.gameboard[target[0]][target[1]].team != self.team
    end
    false
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









