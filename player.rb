class HumanPlayer
  POSITION_MAPPING = {"A" => 0,
                      "B" => 1,
                      "C" => 2,
                      "D" => 3,
                      "E" => 4,
                      "F" => 5,
                      "G" => 6,
                      "H" => 7}

  attr_accessor :team, :game, :captured, :check_mate

  def initialize(team, game)
    @team = team
    @game = game
    @check_mate = false
    @captured = []
  end

  def make_move
    while true
      input = process_input
      
      if valid_move?(input)
        move_piece(input)
        return
      end
    end
  end

  private

  def get_input
    while true
      puts "Where to (ex: A6, B7)?"
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

    y1, y2 = POSITION_MAPPING[(input[0][0].upcase)], POSITION_MAPPING[(input[1][0].upcase)]
    x1, x2 = input[0][1].to_i, input[1][1].to_i

    [[x1, y1], [x2, y2]]
  end

  def move_piece(input)
    start, target = input[0], input[1]
    board = @game.gameboard

    if capture?(start, target)
      @captured << board[target[0]][target[1]]
    end

    board[start[0]][start[1]], board[target[0]][target[1]] = nil, board[start[0]][start[1]]
    
    puts "CHECK" if check?(target)
  end

  def valid_move?(input)
    start, target, board = input[0], input[1], @game.gameboard

    if board[start[0]][start[1]].nil?
      puts "Not a valid move, this space is empty"
      return false
    end

    possible_moves = board[start[0]][start[1]].all_moves(start)

    if board[start[0]][start[1]].team != @team
      puts "This is not your piece"
      return false
    end

    unless board[target[0]][target[1]].nil?
      unless capture?(start, target)
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

  def capture?(start, target)
    board = @game.gameboard

    unless board[start[0]][start[1]].nil? || board[target[0]][target[1]].nil?
      @check_mate = true if board[target[0]][target[1]].class == King
      return true if board[target[0]][target[1]].team != board[start[0]][start[1]].team
    end

    false
  end

  def check?(last_move)
    board = board = @game.gameboard
    possible_moves = board[last_move[0]][last_move[1]].all_moves(last_move)

    possible_moves.each do |coord|
      if board[coord[0]][coord[1]].class == King && board[coord[0]][coord[1]].team != @team
        return true
      end
    end

    false
  end
end