require 'rspec'
require_relative 'chess.rb'

describe 'Game' do
  subject(:game) { Game.new }

  describe "#initialize" do
    it "should create two player instances" do
      game.player1.should_not be_nil
      game.player2.should_not be_nil
    end
  end
  
end

describe 'HumanPlayer' do

end

describe 'Pieces' do

end