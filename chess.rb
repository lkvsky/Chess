require 'yaml'
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
      @gameboard[1] << Pawn.new(self, [1,i])
      @gameboard[1].shift
    end
    8.times do |i|
      @gameboard[6] << Pawn.new(self, [6,i])
      @gameboard[6].shift
    end
  end

  def create_backrow
    front = [Rook.new(self), Knight.new(self), Bishop.new(self), Queen.new(self), King.new(self), Bishop.new(self), Knight.new(self), Rook.new(self)]
    back = [Rook.new(self), Knight.new(self), Bishop.new(self), King.new(self), Queen.new(self), Bishop.new(self), Knight.new(self), Rook.new(self)]
    front.each_with_index do |piece, i|
      piece.current_loc = [0,i]
      @gameboard[0] << piece
      @gameboard[0].shift
    end
    back.each_with_index do |piece, i|
      piece.current_loc = [8,i]
      @gameboard[7] << piece
      @gameboard[7].shift
    end
  end

  def print_gameboard
    @gameboard.each do |row|
      row.each do |square|
        if square.nil?
          print " * "
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
    true
    print_gameboard
    while true
      @player1.make_move
      #print_gameboard
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
  attr_accessor :type, :current_game

  def initialize(type, game)
    type == 1 ? @type = 'w' : @type = 'b'
    @game = game
  end

  def make_move
    puts "Where do you want to go (ex: A6, B7)"
    input = gets.chomp.split(",").map do |pair|
      pair.split(' ').map! { |num| num.to_i }
    end
    validate_move(input)
  end

  def validate_move(input)
    start, target = input[0], input[1]
    @game.gameboard[start[0]][start[1]].find_possible_moves(start)

    if @game.gameboard[target[0]][target[1]].nil?
      if @game.gameboard[start[0]][start[1]].possible_moves.include?(target)
        @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
        @game.print_gameboard
      else
        puts "Not a valid move"
      end
    else
      # If opponents piece is there, you can steal it, other wise...
      puts "Not a valid move"
    end
  end

end

class Piece

  attr_accessor :mark, :current_loc, :direction, :until_blocked, :possible_moves, :game

  def initialize(game, current_loc=[])
    @current_loc = current_loc
    @game = game
  end

  def find_possible_moves(current_loc)
    # look at board
    # compare current loc
    # piece move function
    # return list of possible moves
    @possible_moves = self.direction.map do |coord|
      x = current_loc[0] + coord[0]
      y = current_loc[1] + coord[1]
      [x, y]
    end
    @possible_moves.select! { |pair| @game.gameboard[pair[0]][pair[1]].nil? }
  end

end

class Pawn < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'P'
    @direction = [[1,0]]
    @until_blocked = false
  end


end

class Rook < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'R'
    @direction = [[1,0], [-1,0], [0,-1], [0,1]]
    @until_blocked = true
  end

end

class Knight < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'H'
    @direction = [[-1, 2], [1, 2], [2, -1], [2, 1], [1, -2], [-1, -2], [-2, 1], [-2, -1]]
    @until_blocked = false
  end
end

class Bishop < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'B'
    @direction = [[1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = true
  end
end

class King < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'K'
    @direction = [[1,0], [-1,0], [0,-1], [0,1], [1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = false
  end


end

class Queen < Piece
  def initialize(game, current_loc=[])
    super(game, current_loc)
    @mark = 'Q'
    @direction = [[1,0], [-1,0], [0,-1], [0,1], [1,1], [-1,-1], [1,-1], [-1,1]]
    @until_blocked = true
  end
end


# def inspect
# end








