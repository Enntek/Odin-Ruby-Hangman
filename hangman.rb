# Odin Ruby Project: Hangman
# https://www.theodinproject.com/lessons/ruby-hangman
# Goal: Create hangman with ability to save and load states

# myvar.methods - Object.instance_methods # to see unique methods
# utilize private/public methods
# utilize a module
# instance_variables method
# super
# namespace with modules
# constants
# to_s method override 
# use pry-byebug / binding.pry instead of just puts

# Add:
# limit input to 1 character, raise exception
# game over if out of guesses

require 'pry-byebug'

module Swimmable
  def swim
    puts "Look! I can swim!"
  end
end

module Serializable
  def serialize
    puts 'We can serialize data with this method.'
  end
end

class WordGame
  def description
    puts 'Word games challenge your mind and are great fun too!'
  end
end

class Hangman < WordGame
  include Serializable
  attr_accessor :wins

  def initialize
    intro_description
    @human = Player.new
    @computer = Computer.new
    @wins = 0
    reset_to_new
    play(@secret_word)
  end

  def reset_to_new
    @incorrect_letters = []
    @guesses = 0
    @guess = nil
    set_secret_word
  end

  def set_secret_word
    @secret_word = @computer.random_word.split('')
    # @secret_word = 'TROOPS'.split('')
    @current_progress = @secret_word.map { |letter| '_' }
    puts "The secret word has been established!\n "
  end

  def show_current_progress(word)
    puts "The secret word is: #{@current_progress.join(' ')}"
    puts "\n"
  end

  def play(word)
    loop do
      show_stats
      show_current_progress(@secret_word)
      puts_matches
      guess
      check_guess(@guess, @secret_word)

      if !@current_progress.include?('_')
        show_current_progress(@secret_word)
        win_game
        break
      end

      if @guesses == 10
        game_over
        return
      end
    end

    next_game
  end

  def game_over
    puts "\nYou are out of guesses! Game over!\n "
  end

  def next_game
    puts "Ready for the next game? Enter 'y' to continue."
    gets.chomp
    reset_to_new
    play(@secret_word)
  end

  def puts_matches
    if !@guess.nil?
      tally = @secret_word.count { |letter| letter == @guess }
      puts "There were #{tally} #{@guess}'s in the secret word!".blue
    end
  end

  def guess
    begin
      @guess = @human.input_guess.upcase
      raise 'Invalid input' unless @guess.match(/[a-zA-Z]/) && @guess.length == 1
    rescue
      puts 'Invalid input, please try again.'
      retry
    end

    if !@secret_word.include?(@guess)
      @guesses += 1
      @incorrect_letters << @guess
    end

    @guess
  end
  
  def check_guess(guess, secret_word)
    p secret_word if guess == ['1']

    secret_word.each_with_index do |letter, index|
      if guess.include?(letter)
        @current_progress[index] = letter
      end
    end
  end

  def show_stats
    used_bank = @incorrect_letters.join(' ')
    
    puts "\nGuesses left: #{10 - @guesses}      #{"Incorrect letters:".red} #{used_bank.red} \n"\
          "Wins in a row: #{@wins}\n "
  end

  def intro_description
    puts "\nIntro to Hangman goes here!\n"\
    "This is another line for the intro!\n"\
    "\n"\
  end

  def win_game
    @wins += 1
    puts 'Congrats! You got the secret word!'
  end
end

class Player
  include Swimmable

  def input_guess
    puts "Guess a letter: "
    gets.chomp
  end
end

class Computer
  def random_word
    word_bank = File.readlines('google-10000-english-no-swears.txt')

    word = ''
    loop do
      word = word_bank.sample.delete("\n")
      break if word.length > 4 && word.length < 13
    end
    word.upcase
  end
end

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end
  def default;        "\e[39m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

game = Hangman.new
