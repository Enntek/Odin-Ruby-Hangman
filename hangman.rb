# Odin Ruby Project: Hangman
# https://www.theodinproject.com/lessons/ruby-hangman
# Goal: Create hangman with ability to save and load states

# My notes:
# yaml/msgpack has no .parse method
# yaml throws error if you dump then load non-existent classes, json does not

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
# add instruction to type 'save', 'load', 'quit' 
# limit input to 1 character, raise exception
# save list of correctly guessed words (no repeat plays)
# no game over, when you miss a word, add to losses
# keep track of wins vs losses

# first try to serialize/unserialize with yaml, json, msgpack
# try to unserialize using your own method
# look at all of your instance_variables

require 'pry-byebug'
require 'json'
require 'yaml'
require 'msgpack'

module Swimmable
  def swim
    puts "Look! I can swim!"
  end
end

module Serializable
  @@serializer = JSON
  @@file_type = 'json' if @@serializer == JSON


  def serialize
    obj = {}
    instance_variables.map do |var|
      next if var == :@load
      next if var == :@human
      next if var == :@computer

      obj[var] = instance_variable_get(var)
    end

    serial_str = @@serializer.dump(obj)

    Dir.mkdir('game_saves') unless Dir.exist?('game_saves')
    fname = "game_saves/hangman_save.#{@@file_type}"
    File.open(fname, 'w') { |file| file.write(serial_str)}

    # Using .to_json
    # File.open("game_saves/hangman_save.json","w") do |f|
    #   f.write(obj.to_json)
    # end
  end

  def unserialize
    fname = File.read("game_saves/hangman_save.#{@@file_type}")

    # obj = @@serializer.parse(fname) # parse seems to be preferred for json
    obj = @@serializer.load(fname)

    obj.keys.each do |key|
      instance_variable_set(key, obj[key])
    end
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
    ask_load_game
    # @start_option = 1

    if @start_option == 1
      new_game
    elsif @start_option == 2
      load_game
    end
  end

  def load_game
    @start_option == nil
    @human = Player.new
    @computer = Computer.new
    puts 'Loading game...'.bg_green
    unserialize
    play
  end

  def new_game
    @human = Player.new
    @computer = Computer.new
    @wins = 0
    reset_to_new
    play
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
    puts "    The secret word is: #{@current_progress.join(' ')}"
    puts "\n"
  end

  def play
    loop do
      show_stats
      show_current_progress(@secret_word)
      msg_about_guess
      guess

      if @guess == 'SAVE'
        serialize
      elsif @guess == 'QUIT'
        quit_game
      else
        check_guess(@guess, @secret_word)
      end

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

  def quit_game
    puts "\nSee you later!\n "
    exit(true)
  end

  def game_over
    puts "\nYou are out of guesses! The secret word was \"#{@secret_word.join}\"!\n"\
          "Game over!\n "
  end

  def next_game
    puts "Ready for the next game? Enter 'y' to continue."
    gets.chomp
    reset_to_new
    play
  end

  def msg_about_guess
    if @guess == 'SAVE'
      puts 'Game is saved!'.bg_green
    else
      if !@guess.nil?
        tally = @secret_word.count { |letter| letter == @guess }
        puts "There were #{tally} #{@guess}'s in the secret word!".blue
      end
    end
  end

  def guess
    begin
      @guess = @human.input_guess.upcase

      raise 'Invalid input' unless (@guess.match(/[a-zA-Z]/) && @guess.length == 1) || @guess =='SAVE' || @guess == 'QUIT'
    rescue
      puts 'Invalid input, please try again.'.bg_red
      retry
    end

    if !@secret_word.include?(@guess) && @guess != 'SAVE'
      @guesses += 1
      @incorrect_letters << @guess
    end

    @guess
  end
  
  def check_guess(guess, secret_word)

    secret_word.each_with_index do |letter, index|
      if guess.include?(letter)
        @current_progress[index] = letter
      end
    end
  end

  def show_stats
    used_bank = @incorrect_letters.join(' ')
    puts "\n "
    puts "Tip: Type 'save' or 'quit' at anytime".bg_gray
    puts "\n "
    puts "\n    Wins in a row: #{@wins}".gray
    puts "    Guesses left: #{10 - @guesses}      #{"Incorrect letters:".red} #{used_bank.red} \n "\
  end

  def intro_description
    puts "\nIntro to Hangman goes here!\n"\
    "This is another line for the intro!\n"\
    "\n"\
  end

  def ask_load_game
    puts "    1. New game \n"\
          "    2. Load game \n"\
          "    3. Quit \n"\
          "\n"\
          "Please make a selection: \n"

    input = gets.chomp.to_i

    case input
    when 1
      @start_option = 1
    when 2
      @start_option = 2
    when 3
      puts "Ok, see you later!"
      exit
    end
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

exit

