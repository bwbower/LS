class GuessingGame
  def initialize
    display_welcome_message
  end

  def play
    loop do
      @previous_guesses = Array.new
      @remaining_guesses = 8
      generate_secret_number
      main_game_loop ? display_winning_message : display_out_of_guesses
      break unless play_again?
      clear_terminal
    end
    display_goodbye_message
  end

  private

  attr_reader :secret_number, :previous_guesses
  attr_accessor :remaining_guesses, :guess

  def main_game_loop
    loop do
      display_guesses_remaining
      display_instructions
      display_previous_guesses
      @guess = user_inputs_guess
      clear_terminal
      return true if guess == secret_number
      display_guess_result
      return false if remaining_guesses == 0
    end
  end

  def generate_secret_number
    @secret_number = (1..100).to_a.sample
  end

  def user_inputs_guess
    loop do
      answer = gets.chomp.to_i
      if valid_guess?(answer)
        previous_guesses << answer
        decrement_remaining_guesses
        break answer
      end
      puts "Invalid guess"
      display_instructions
    end
  end

  def valid_guess?(answer)
    (1..100).include?(answer)
  end

  def evaluate_guess
    case guess
    when (0..secret_number) then 'low'
    when (secret_number..100) then 'high'
    end
  end

  def decrement_remaining_guesses
    self.remaining_guesses = remaining_guesses - 1
  end

  def play_again?
    puts "Would you like to play again?"
    answer = gets.chomp.downcase
    return true if answer == ('y' || 'yes')
    false
  end

  def display_welcome_message
    clear_terminal
    puts Banner.new("Welcome to the Guessing Game!")
    sleep 1.5
    clear_terminal
  end

  def display_instructions
    puts "Enter a number between 1 and 100!"
  end

  def display_guesses_remaining
    puts "You have #{remaining_guesses} guesses left"
  end

  def display_previous_guesses
    puts "So far you've guessed: #{previous_guesses}"
  end

  def display_guess_result
    puts "Your guess is too #{evaluate_guess}"
  end

  def display_winning_message
    clear_terminal
    puts Banner.new("You won!")
  end

  def display_out_of_guesses
    clear_terminal
    puts Banner.new("You have no more guesses. You lost.")
  end

  def display_goodbye_message
    clear_terminal
    puts Banner.new("Thanks for playing! Goodbye!")
  end

  def clear_terminal
    system 'clear'
  end
end

class Banner
  def initialize(message, banner_size=message.length)
    @message = message
    @banner_size = banner_size
  end

  private

  def length_modifier
    ' ' * ((@banner_size - @message.length) / 2)
  end

  def horizontal_rule
    "+-#{('-' * @banner_size)}-+"
  end

  def empty_line
    "| #{(' ' * @banner_size)} |"
  end

  def message_line
    "|#{length_modifier} #{@message} #{length_modifier}|"
  end

  def to_s
    [horizontal_rule, empty_line, message_line,
     empty_line, horizontal_rule].join("\n")
  end
end

game = GuessingGame.new
game.play
