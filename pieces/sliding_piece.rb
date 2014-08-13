class SlidingPiece < Piece
  STRAIGHT_DIRS = [
    [ 1, 0], [0,  1],
    [-1, 0], [0, -1]
  ]
  
  DIAGONAL_DIRS = [
    [ 1, 1], [ 1, -1],
    [-1, 1], [-1, -1]
  ]
  
  def moves
    moves = []
    dirs = move_dirs
    
    dirs.each do |rank_offset, file_offset|
      current_pos = @position.dup
      
      while true 
        current_pos.rank += rank_offset
        current_pos.file += file_offset

        break unless valid_move?(current_pos)
        
        moves << current_pos.dup
        
        break if attack?(current_pos)
      end 
    end
    
    moves
  end
  
  private
  
  def attack? position
    @board[position] && @board[position].color != @color
  end
end