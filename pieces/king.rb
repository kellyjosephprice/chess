# encoding: utf-8

class King < SteppingPiece
  def move(position)
    
    if is_castle?(position)      
      if @position.file - position.file > 1
        rook = @board[[@position.rank, 0]]
        rook.move([@position.rank, 3])
      else
        rook = @board[[@position.rank, 7]]
        rook.move([@position.rank, 5])
      end
    end
    
    super
  end
  
  def to_s
   @color == :white ? '♔' : '♚'
  end
  
  private
  
  def is_castle? position
    (@position.file - position.file).abs == 2
  end
  
  def move_offsets
    ([-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]).concat(castles)
  end
  
  def castles
    return [] if @moved
    
    left = castle([1, 2, 3], [@position.rank, 0], -1)
    right = castle([5, 6], [@position.rank, 7], 1)
    
    [left, right].compact
  end
  
  def castle(empty_files, rook_pos, direction)
    rank = @position.rank
    rook = @board[rook_pos]
    
    return nil unless rook.is_a?(Rook) && !rook.moved
    return nil unless empty_files.all? { |file| @board[[rank, file]].nil? }
    
    [0, direction * 2] unless move_into_check?([rank, @position.file + direction])
  end
end