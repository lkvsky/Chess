require 'rspec'
require_relative 'chess.rb'

describe 'Game' do
  subject(:game) { Game.new }

  describe "#initialize" do
    it "should create two player instances" do
      game.player1.should_not be_nil
      game.player2.should_not be_nil
    end

    it "should generate a chess board" do
      game.gameboard.each { |row| row.length.should == 8}
      game.gameboard.length.should == 8
    end

    it "should have pieces on the board" do
      game.gameboard[0].each { |tile| tile.should_not be_nil }
      game.gameboard[1].each { |tile| tile.should_not be_nil }
      game.gameboard[6].each { |tile| tile.should_not be_nil }
      game.gameboard[7].each { |tile| tile.should_not be_nil }
    end
  end
  
end

describe 'HumanPlayer' do
  let(:game) { double("Game", :gameboard => Array.new(8) { Array.new(8) }) }

  let(:piece1) { double("Pieces", :team => 1 ) }
  let(:piece2) { double("Pieces", :team => 2 ) }

  subject(:player1) { HumanPlayer.new(1, game) }
  subject(:player2) { HumanPlayer.new(2, game)}

  context "filled board" do
    before(:each) do
      game.gameboard[0].map! { |square| square = piece1 }
      game.gameboard[1].map! { |square| square = piece1 }
      game.gameboard[6].map! { |square| square = piece2 }
      game.gameboard[7].map! { |square| square = piece2 }
    end

    describe "#initialize" do
      it "should belong to a different team than its competitor" do
        player1.team.should_not == player2.team
      end
    end

    describe "#valid_move?" do
      it "should not let a player pick an empty space" do
        player1.space_empty?([[2, 2], [3, 2]]).should be_false
        player1.space_empty?([[1, 0], [2, 0]]).should be_true
      end

      it "should not let a player choose another player's piece" do
        player1.your_piece?([[6, 0], [5, 0]]).should be_false
        player2.your_piece?([[6, 0], [5, 0]]).should be_true
      end

      it "should not let a player capture it's own piece" do
        player1.your_piece?([[1, 0], [0, 0]]).should be_false
      end
    end
  end
end

describe 'Pieces' do
  let(:game) { double("Game", :gameboard => Array.new(8) { Array.new(8) }) }
  subject(:piece) { Piece.new(game, 1) }

  describe "#valid_position" do
    it "should return false for spots off of the board" do
      piece.valid_position?(8, 8).should be_false
      piece.valid_position?(-1, -1).should be_false
    end
  end

  context "pawn cases" do
    subject(:pawn1) { Pawn.new(game, 1) }
    subject(:pawn2) { Pawn.new(game, 2) }

    before(:each) do
      game.gameboard[1].map! { |tile| tile = pawn1 }
      game.gameboard[6].map! { |tile| tile = pawn2 }
    end

    describe "#pawn_moves" do
      it "should have 1 natural direction" do
        pawn1.direction.length.should == 1
      end

      it "should be allowed to move 2 spaces on first move" do
        pawn1.first_move.should be_true
        pawn1.pawn_moves([1, 0]).should include([3, 0])
        pawn2.first_move = false
        pawn2.pawn_moves([6, 0]).should_not include([4, 0])
      end

      it "should only be allowed to capture a piece diagonally" do
        game.gameboard[2][1] = pawn2
        pawn1.pawn_moves([1, 0]).should include([2, 1])
        game.gameboard[2][2] = pawn2
        pawn1.pawn_moves([1, 2]).should_not include([2, 2])
      end
    end
  end

  context "pieces that can move more than one space" do
    subject(:rook) { Rook.new(game, 1) }
    subject(:bishop) { Bishop.new(game, 1) }
    subject(:queen) { Queen.new(game, 1) }
    subject(:pawn) { Pawn.new(game, 1) }

    describe "#find_possible_trail" do
      it "should have attribute 'until_blocked' " do
        rook.until_blocked.should be_true
        bishop.until_blocked.should be_true
        queen.until_blocked.should be_true
        pawn.until_blocked.should be_false
      end

      it "rook should be able to move in a straight line" do
        game.gameboard[0][0] = rook
        rook.find_possible_trail([0, 0]).should include([0, 7])
        rook.find_possible_trail([0, 0]).should include([7, 0])
        rook.find_possible_trail([0, 0]).should_not include([1, 1])
      end

      it "bishop should be able to move diagonally" do
        game.gameboard[0][0] = bishop
        bishop.find_possible_trail([0, 0]).should include([7, 7])
        bishop.find_possible_trail([0, 0]).should_not include([7, 0])       
      end

      it "queen should be able to go anywhere" do
        game.gameboard[0][0] = queen
        queen.find_possible_trail([0, 0]).should include([7, 7])
        queen.find_possible_trail([0, 0]).should include([7, 0])         
      end
    end
  end
end