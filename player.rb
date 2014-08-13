class Player
  attr_reader :color
    
  def initialize(color, board)
    @color = color
    @board = board
  end
  
  def get_move
    result = {}
    
    begin
      print "Enter your move: "
      moves = gets.chomp.split(' ')
    
      start = parse_coordinate(moves[0])
      dest = parse_coordinate(moves[1])
    rescue ArgumentError
      retry
    end
    
    if @board[start].color != @color
      raise InvalidMoveError.new(
        "Piece at #{ start.pgn } does not belong to #{ @color }.")
    end
    
    result[:start] = start
    result[:dest] = dest
    
    result
  end
  
  private
  
  def parse_coordinate(coord)
    raise ArgumentError if coord.nil? || coord.size != 2
    
    rank = Integer(coord[1]) - 1
    file = ('a'..'h').to_a.index(coord[0])
    
    raise ArgumentError if file.nil?
    
    position = [rank, file]
    
    raise ArgumentError unless Board.in_bounds?(position)
    
    position
  end 
end