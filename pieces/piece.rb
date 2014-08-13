class Piece
  attr_reader :color, :position, :moved
  attr_writer :board
  
  def initialize(color, pos, board, moved = false)
    @color = color
    @position = pos
    @board = board
    @moved = moved
  end
  
  def dup
    self.class.new(@color, @position.dup, nil, @moved)
  end
  
  def to_s
    self.class.to_s[0]
  end
  
  def move(position)
    @board[position] = self
    @board[@position] = nil
    @position = position
  end
  
  def legal_moves
    moves.select { |m| !move_into_check?(m) }
  end
  
  private
  
  def valid_move? position
    return false unless Board.in_bounds?(position) 
    
    square = @board[position]
    (square.nil? || square.color != @color)
  end
  
  def move_into_check? position
    duped_board = @board.dup
    
    duped_board[@position].move(position)
    duped_board.in_check?(@color)
  end
end

class NilClass
  def to_s
    ' '
  end
end