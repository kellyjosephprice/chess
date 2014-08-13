require './board'
require './players'
require './position'

class Game
  attr_reader :board, :moves
  
  def initialize(players)
    @board = Board.new
    
    @white_player, @black_player = players
    @current_player = @white_player
  end
  
  def self.load(path)
    YAML::load_file(path)
  end
  
  def prompt_save    
    begin
      print "Save the game (y/n)? "
      answer = gets.chomp.downcase
    end until ['y', 'n'].include? answer
    
    game.save("games/" + Time.now.strftime('%F-%T.game')) if answer == 'y'
  end
  
  def save(path)
    print "Saving..."
    
    File.open(path, 'w') do |file|
      file << self.to_yaml
    end
    
    puts "done!"
  end
  
  def players
    [@white_player, @black_player]
  end
  
  def play
    until game_over?
      render_board
      
      once_for_local { |p| p.say("#{ @current_player.color.capitalize } to play.")}
      
      begin
        move = @current_player.get_move
        do_move(move)       
      rescue InvalidMoveError => error
        @current_player.error(error.message)
        retry
      end
      
      cycle_player
    end
    
    render_board
    
    if @board.stalemate?(@current_player.color)
      once_for_local { |p| p.say("It's a draw!") }
    else  
      winner = next_player
      loser = @current_player
      
      winner.say("Congratulations, #{ winner.color }!")
      loser.say("Too bad, #{ loser.color }!")
    end
    
    once_for_local { |p| p.end_game }
  end
  
  private
  
  def do_move(move)    
    @board.move(@current_player.color, move[:start], move[:dest])
    
    if @board.promoting?(@current_player.color)
      promotion = @current_player.get_promotion
      
      @board.promote(@current_player.color, promotion)
    end    
  end
  
  def cycle_player
    @current_player = next_player
  end
  
  def game_over?
    @board.checkmate?(:white) || @board.checkmate?(:black) || @board.stalemate?(@current_player.color)
  end
  
  def render_board
    once_for_local { |p| p.update_board(@board) }
  end
  
  def once_for_local
    if players.all? { |p| p.is_a? NetworkPlayer }
      players.each { |p| yield(p) }
    else
      yield(@current_player)
    end
  end
  
  def next_player
    @current_player == @white_player ? @black_player : @white_player
  end
end

if __FILE__ == $PROGRAM_NAME  
  path = ARGV.shift
  players = [Player.new(:white, 600), Player.new(:black, 600)]
  
  game = path.nil? ? Game.new(players) : Game.load(path)
  
  trap('SIGINT') do
    puts
    puts
    
    game.prompt_save
    
    puts "Goodbye!"
    
    exit
  end
 
  begin 
    game.play
  rescue StandardError => error
    puts error.message    
    game.save("games/" + Time.now.strftime('%F-%T.game'))
  end
end
