require './board'
require './player'
require 'debugger'

# possibilities
#   en passant etc
#   save/load game
#   chess960

class Game
  attr_reader :board
  
  def initialize
    @board = Board.new
    
    @white_player = Player.new(:white, @board)
    @black_player = Player.new(:black, @board)
    
    @current_player = @white_player
  end
  
  def play
    until game_over?
      render_board
      
      puts
      
      puts "#{ @current_player.color.capitalize } to play."
      
      begin
        move = @current_player.get_move
        @board.move(move[:start], move[:dest])
      rescue InvalidMoveError => error
        puts error.message
        retry
      end
      
      @current_player = next_player
    end
    
    render_board
    
    if @board.stalemate?(@current_player.color)
      puts "It's a draw"
    else  
      puts "Congratulations, #{ next_player.color }!"
    end
  end
  
  private
  
  def game_over?
    @board.checkmate?(:white) || @board.checkmate?(:black) || @board.stalemate?(@current_player.color)
  end
  
  def render_board
    puts @board.to_s(@current_player == @black_player)
  end
  
  def next_player
    @current_player == @white_player ? @black_player : @white_player
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end