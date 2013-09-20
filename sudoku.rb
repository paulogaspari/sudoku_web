

require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions


def random_sudoku
    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    # then we solve this (really hard!) sudoku
    sudoku.solve!
    # and give the output to the view as an array of chars
    sudoku.to_s.chars
end



def puzzle(sudoku)
  sudoku_level = 45
  indexes = []
  puzzle = sudoku.dup

  until indexes.count == sudoku_level do
    indexes << rand(80)
    indexes.uniq!
  end

  indexes.each {|index| puzzle[index] = nil}
  puzzle
end
  # there is a little bug, because the last cell is always populated



get '/' do
  sudoku = random_sudoku
  session[:solution] = sudoku
  @current_solution = puzzle(sudoku)
  erb :index
end


get '/solution' do 
  @current_solution = session[:solution]
  erb :index
end 





# ["4", "6", "3", "9", "7", "1", "5", "8", "2", "1", "2", "5", "3", "4", "8", "6", "7", "9", "7", "8", "9", "2", "5", "6", "1", "3", "4", "2", "1", "4", "5", "3", "7", "8", "9", "6", "3", "5", "6", "1", "8", "9", "2", "4", "7", "8", "9", "7", "4", "6", "2", "3", "1", "5", "5", "3", "1", "6", "9", "4", "7", "2", "8", "6", "4", "8", "7", "2", "3", "9", "5", "1", "9", "7", "2", "8", "1", "5", "4", "6", "3"]