

require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions

set :session_secret, "I'm the secret key to sign the cookie"





get '/' do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end


# post '/' do
#   cells = params["cell"]
#   session[:current_solution] = cells.map{|value| value.to_i }.join
#   session[:check_solution] = true
#   redirect to ('/')
# end



post '/' do
  boxes = params["cell"].each_slice(9).to_a
  cells = (0..8).to_a.inject([]) {|memo, i|
    memo += boxes[i/3*3, 3].map{|box| box[i%3*3, 3] }.flatten
  }
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end





get '/solution' do 
  @current_solution = session[:solution]
  erb :index
end 

# get '/solution' do 
#   @current_solution = session[:solution]
#   erb :index
# end 

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
  sudoku_level = 75
  indexes = (0..80).to_a.sample(81-sudoku_level)
  puzzle = sudoku.dup
  indexes.each {|index| puzzle[index] = "0"}
  puzzle
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
    must_be_guessed = puzzle_value == "0"
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




