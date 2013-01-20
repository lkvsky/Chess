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
    y1 = POSITION_MAPPING[(input[0][0].upcase)]
    y2 = POSITION_MAPPING[(input[1][0].upcase)]
    x1 = input[0][1].to_i
    x2 = input[1][1].to_i
    [[x1, y1], [x2, y2]]
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
    possible_moves = @game.gameboard[start[0]][start[1]].all_moves(start)

    if @game.gameboard[start[0]][start[1]].nil?
      puts "Not a valid move, this space is empty"
      return false
    end

    if @game.gameboard[start[0]][start[1]].team != @team
      puts "This is not your piece"
      return false
    end

    unless @game.gameboard[target[0]][target[1]].nil?
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
    unless @game.gameboard[start[0]][start[1]].nil? || @game.gameboard[target[0]][target[1]].nil?
      return true if @game.gameboard[target[0]][target[1]].team != @game.gameboard[start[0]][start[1]].team
    end
    false
  end
  # at end of each move, check if the target piece can put king in jeopardy
  def check?(last_move)
    possible_moves = @game.gameboard[last_move[0]][last_move[1]].all_moves(last_move)
    possible_moves.each do |coord|
      return true if @game.gameboard[coord[0]][coord[1]].class == King && @game.gameboard[coord[0]][coord[1]].team != @team
    end
    false
  end
  # then check if check_mate
  def check_mate?(last_move)
    king = nil
    @game.gameboard.each do |row|
      row.each do |square|
        king = square if square.class == King && square.team != @team
      end
    end
    return true if check?(last_move) && check?(king)
    false
  end

  def move_piece(input)
    start = input[0]
    target = input[1]
    if !capture?(start, target)
      @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
    else
      @captured << @game.gameboard[target[0]][target[1]]
      @game.gameboard[start[0]][start[1]], @game.gameboard[target[0]][target[1]] = nil, @game.gameboard[start[0]][start[1]]
    end
    puts "GAME OVER" if check_mate?(target)
    puts "CHECK" if check?(target)
  end

end