class Participant
  attr_accessor :hand, :total

  def initialize
    @hand = []
  end

  def calculate_total
    @total = hand.map(&:value)
    index = 0

    while convert_aces?
      total[index] = 1 if total[index] == 11
      index += 1
    end

    total.sum
  end

  def busted?
    calculate_total > 21
  end

  def show_hand
    hand.join("\n  - ")
  end

  private

  DEALER_NAMES = %w(Biff Scooter)

  def convert_aces?
    total.sum > 21 && total.include?(11)
  end
end

class Deck
  attr_reader :deck

  def initialize
    reset_deck
  end

  def deal
    reset_deck if deck.empty?
    deck.pop
  end

  private

  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def reset_deck
    @deck = build_deck
  end

  def build_deck
    SUITS.flat_map do |suit|
      RANKS.map { |rank| Card.new(rank, suit) }
    end.shuffle
  end
end

class Card
  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    VALUES.fetch(rank, rank)
  end

  private

  VALUES = { 'Jack' => 10, 'Queen' => 10, 'King' => 10, 'Ace' => 11 }

  attr_reader :rank, :suit

  def to_s
    "the #{rank} of #{suit}"
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

class Game
  def initialize
    @player = Participant.new
    @dealer = Participant.new
    @deck = Deck.new
    @dealer_name = Participant::DEALER_NAMES.sample
  end

  def start
    clear_terminal
    display_welcome_message
    main_game_loop
    display_goodbye_message
  end

  private

  attr_reader :player, :dealer, :deck, :dealer_name

  def main_game_loop
    loop do
      initial_deal
      display_cards
      player_turn
      dealer_turn unless player.busted?
      display_result_of_round
      reset_hand
      break unless play_again?
    end
  end

  def player_turn
    loop do
      clear_terminal
      display_cards
      break if player.busted?
      break unless player_hit?
    end
  end

  def dealer_turn
    loop do
      clear_terminal
      display_player_cards
      display_dealer_cards
      sleep 2
      break if dealer.busted?
      break unless dealer_hit?
    end
  end

  def initial_deal
    2.times do
      player.hand << deck.deal
      dealer.hand << deck.deal
    end
  end

  def hit(participant)
    participant.hand << deck.deal
  end

  def player_hit?
    puts "Hit or Stay?"
    answer = gets.chomp.downcase
    valid_input?(answer)
    return false if answer == 'stay'
    hit(player)
  end

  def dealer_hit?
    dealer.calculate_total < 17 ? hit(dealer) : false
  end

  def reset_hand
    player.hand.clear
    dealer.hand.clear
  end

  def play_again?
    puts "Would you like to play again? (y/n)"
    answer = gets.chomp.downcase
    answer == 'y'
  end

  def valid_input?(answer)
    loop do
      break if answer == 'hit' || answer == 'stay'
      puts "Sorry, please type 'Hit' or 'Stay'"
      answer = gets.chomp.downcase
    end
  end

  def display_welcome_message
    puts Banner.new("Welcome to Twenty-One!")
    sleep 1.75
    clear_terminal
    puts "Your dealer's name is #{dealer_name}"
    puts "He's shuffling the deck..."
    sleep 3
  end

  def display_cards
    display_player_cards
    puts "#{dealer_name} is showing #{dealer.hand[0]}"
    empty_line
  end

  def display_player_cards
    puts "You've got:\n  - #{player.show_hand}"
    puts "You have #{player.calculate_total} points!"
    empty_line
  end

  def display_dealer_cards
    puts "#{dealer_name} has:\n  - #{dealer.show_hand}"
    puts "#{dealer_name} has #{dealer.calculate_total} points"
    empty_line
  end

  def display_result_of_round
    if player.busted?
      puts "You busted! #{dealer_name} wins!"
    elsif dealer.busted?
      puts "#{dealer_name} busted! You win!"
    elsif player.calculate_total > dealer.calculate_total
      puts "You won!"
    else
      puts "#{dealer_name} wins"
    end
  end

  def display_goodbye_message
    clear_terminal
    puts Banner.new("Thanks for playing! Goodbye")
  end

  def empty_line
    puts ""
  end

  def clear_terminal
    system 'clear'
  end
end

Game.new.start
