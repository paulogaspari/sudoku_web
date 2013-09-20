

require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions


get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  sudoku = random_sudoku
  session[:solution] = sudoku
  @solution = session[:solution]
  @current_solution = puzzle(sudoku)
  # raise @solution.inspect
  erb :index
end

post '/' do
  cells = params["cell"]
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to ('/')
end

get '/solution' do 
  @current_solution = session[:solution]
  erb :index
end 



#####################################################################

#####################################################################


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
  @puzzle = sudoku.dup

  until indexes.count == sudoku_level do
    indexes << rand(80)
    indexes.uniq!
  end

  indexes.each {|index| @puzzle[index] = 0}
  @puzzle
end
  # there is a little bug, because the last cell is always populated

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]    
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end


helpers do

  def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
    must_be_guessed = puzzle_value == 0
    # I needed to change this 0 to "0" otherwise all the cells show up as value provided
    tried_to_guess = current_solution_value.to_i != 0
    guessed_incorrectly = current_solution_value != solution_value

    if solution_to_check && must_be_guessed && tried_to_guess && guessed_incorrectly
      'incorrect'
    elsif !must_be_guessed
      'value-provided'
    end
  end

  def cell_value(value)
    value.to_i == 0 ? '' : value
  end

end




