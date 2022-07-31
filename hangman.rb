# Odin Ruby Project: Hangman
# https://www.theodinproject.com/lessons/ruby-hangman
# Goal: Create hangman with ability to save and load states

# somevar.methods - Object.instance_methods # to see unique methods

require 'pry-byebug'

word_bank = File.readlines('google-10000-english-no-swears.txt')
# word_bank = File.readlines('short_bank.txt')
word = ''

loop do
  word = word_bank.sample.delete("\n")
  break if word.length > 4
end

p word

exit