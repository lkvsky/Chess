require 'yaml'

require './player.rb'
require './pieces.rb'

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