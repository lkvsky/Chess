class Game
  attr_accessor :gameboard

  def initialize
  end

  def create_gameboard
    @gameboard = Array.new(8){Array.new(8)}
    create_pawns
    p @gameboard
    create_backrow
    print_gameboard
  end

  def create_pawns
    8.times do |i|
      @gameboard[1] << Pawn.new([1,i])
      @gameboard[1].shift
    end
    8.times do |i|
      @gameboard[6] << Pawn.new([6,i])
      @gameboard[6].shift
    end
  end

  def create_backrow
    front = [Rook.new, Knight.new, Bishop.new, Queen.new, King.new, Bishop.new, Knight.new, Rook.new]
    back = [Rook.new, Knight.new, Bishop.new, King.new, Queen.new, Bishop.new, Knight.new, Rook.new]
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
    until won?
      @player1.make_move
      @player2.make_move
    end
  end

  def user_settings
    @player1, @player2 = HumanPlayer.new(1), HumanPlayer.new(2)
  end
end


class HumanPlayer
  attr_accessor :type

  def initialize(type)
    type == 1 ? @type = 'w' : @type = 'b'
  end

  def make_move
    puts "Where do you want to go (ex: A6, B7)"
    input = gets.chomp.split(",")
    # start, target = input[0], input[1]
    # [start, target]
    validate_move(input)
  end

  def validate_move(input)

    # look at board at start location
    # grab that object
    # object.possible_moves.include?(target_location)
  end


end



class Piece

  attr_accessor :mark, :current_loc

  def initialize(current_loc=[])
    @current_loc = current_loc
  end

  def self.possible_moves(current_loc)

    # look at board
    # compare current loc
    # piece move function
    # return list of possible moves
  end

end

class Pawn < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'P'
  end
end

class Rook < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'R'
  end
end

class Knight < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'H'
  end
end

class Bishop < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'B'
  end
end

class King < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'K'
  end
end

class Queen < Piece
  def initialize(current_loc=[])
    super(current_loc)
    @mark = 'Q'
  end
end











