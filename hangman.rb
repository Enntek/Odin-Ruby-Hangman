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

# to print out underscores + correct letters:
# use map on the secret word
# check if each letter is in your guess
# if not, return an underscore
# if so, return the letter
# the array will be both underscores and letters

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

  def initialize
    intro
    @human = Player.new
    @computer = Computer.new
    establish_secret_word
    print_hidden_word(@secret_word)

    # play(@secret_word)
  end

  def establish_secret_word
    # @secret_word = @computer.random_word.split('')
    @secret_word = 'HAMSTER'
  end

  def print_hidden_word(word)
    array = word.split('').map { |letter| '_ ' }

    word_hidden = array.join(' ')
    puts "The secret word is: #{word_hidden}"
    puts "\n"
  end


  def play(word)
    loop do
      guess = @human.input_guess
      if guess == @secret_word
        puts 'You guessed the secret word!'
      else
        puts 'Try again!'
      end
      break
    end
  end

  def intro
    puts "\nIntro to Hangman goes here!\n"\
    "This is another line for the intro!\n"\
    "\n"\
  end
end

class Player
  include Swimmable

  def input_guess
    puts "Guess the word: "
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
    word
  end
end

game = Hangman.new
# game.serialize