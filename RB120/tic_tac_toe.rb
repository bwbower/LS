require 'pry-byebug'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  attr_reader :squares
  attr_accessor :defensive_move

  def initialize
    @squares = {}
    reset
  end

  def draw
    puts "[#{@squares[1]}][#{@squares[2]}][#{@squares[3]}]"
    puts "[#{@squares[4]}][#{@squares[5]}][#{@squares[6]}]"
    puts "[#{@squares[7]}][#{@squares[8]}][#{@squares[9]}]"
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return (squares.first.marker)
      end
    end
    nil
  end

  def ai_defense_needed?
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if two_identical_markers?(squares)
        @defensive_move = determine_defensive_move(squares).join.to_i
        return true
      end
    end
    false
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def unmarked_squares
    @squares.values.select(&:unmarked?)
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  private

  def determine_defensive_move(squares)
    @squares.select do |_, v|
      squares.select do |square|
        unmarked_squares.include?(square)
      end.include?(v)
    end.keys
  end

  def two_identical_markers?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 2
    markers.uniq.size == 1
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  COMPUTER_NAMES = %w(HAL9000 R2-D2 Turing DeepThought Project2501)

  attr_reader :marker
  attr_accessor :name

  def initialize(marker)
    @marker = marker
    @name = COMPUTER_NAMES.sample
  end

  def set_name
    puts "What's your name?"
    @name = gets.chomp.capitalize
  end
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  FIRST_TO_MOVE = HUMAN_MARKER

  attr_reader :board, :human, :computer
  attr_accessor :human_score, :computer_score

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
    @human_score = 0
    @computer_score = 0
  end

  def play
    clear_terminal
    display_welcome_message
    human.set_name
    pick_your_marker
    main_game
    display_goodbye_message
  end

  def pick_your_marker
    clear_terminal
    puts "Pick your marker, #{human.name}!"
    HUMAN_MARKER.replace(gets.chomp.to_s.upcase)
    COMPUTER_MARKER.replace('X') if HUMAN_MARKER == 'O'
    clear_terminal
  end

  # private

  def main_game
    loop do
      game_round
      display_final_score
      display_play_again_message
      break unless play_again?
    end
  end

  def game_round
    loop do
      display_board
      player_moves
      display_result
      tally_score
      display_score
      break if winner?
      reset
    end
  end

  def player_moves
    loop do
      current_player_moves
      break if board.full? || board.someone_won?
      clear_screen_and_display_board
    end
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_moves
    puts "Choose a square: (#{joiner(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid square"
    end

    board[square] = human.marker
  end

  def computer_moves
    if board.ai_defense_needed?
      board[board.defensive_move] = computer.marker
    else
      board[board.unmarked_keys.sample] = computer.marker
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def tally_score
    case board.winning_marker
    when human.marker then @human_score += 1
    when computer.marker then @computer_score += 1
    end
  end

  def winner?
    return true if (human_score || computer_score) == 5
    false
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear_terminal
  end

  def joiner(array, delimiter=', ', word='or')
    case array.size
    when 0 then ''
    when 1 then array.first
    when 2 then array.join(" #{word} ")
    else
      array[-1] = "#{word} #{array[-1]}"
      array.join(delimiter)
    end
  end

  def clear_terminal
    system 'clear'
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    sleep 1
    puts "Today you're playing against #{computer.name}!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe, #{human.name}!"
  end

  def display_board
    puts "#{human.name} is an #{human.marker}"
    puts "#{computer.name} is an #{computer.marker}"
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear_terminal
    display_board
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker then puts "#{human.name} won!"
    when computer.marker then puts "#{computer.name} won!"
    else "The board is full!"
    end
  end

  def display_score
    puts "#{computer.name} has #{computer_score} points"
    puts "#{human.name} has #{human_score} points"
    sleep 2
  end

  def display_final_score
    if computer_score == 5
      puts "#{computer.name} won the game!"
    elsif human_score == 5
      puts "#{human.name} won the game!"
    end
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
