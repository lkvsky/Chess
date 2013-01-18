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
      unless kill?(start, target)
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

  def kill?(start, target)
    unless @game.gameboard[start[0]][start[1]].nil? || @game.gameboard[target[0]][target[1]].nil?
      return true if @game.gameboard[target[0]][target[1]].team != @game.gameboard[start[0]][start[1]].team
    end
    false
  end
  # TO DO: moved from pieces class, refactor to make sense in human class
  def king_captured?(target)
    target.class == King && target.team != self.team
  end

  def move_piece(input)
    start = input[0]
    target = input[1]
    if !@game.gameboard[start[0]][start[1]].kill?(target)
      @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
    else
      if @game.gameboard[start[0]][start[1]].king_captured?(target)
        puts "GAME OVER"
        return
      else
        @captured << @game.gameboard[target[0]][target[1]]
        @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
      end
    end
  end

end