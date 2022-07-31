# Odin Ruby Project: Hangman
# https://www.theodinproject.com/lessons/ruby-hangman
# Goal: Create hangman with ability to save and load states

# somevar.methods - Object.instance_methods # to see unique methods
# utilize private/public methods
# utilize a module
# instance_variables method
# super
# namespace with modules
# constants
# to_s method override 
# use pry-byebug / binding.pry instead of just puts

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
  include Serializable
end

class Hangman < WordGame
end

class Player
  include Swimmable
end

class Computer
  def random_word
    word_bank = File.readlines('google-10000-english-no-swears.txt')
    
    word = ''
    loop do
      word = word_bank.sample.delete("\n")
      break if word.length > 4
    end
    word
  end
end


jon = Player.new
jon.swim

game = Hangman.new
game.serialize

Hangman.new