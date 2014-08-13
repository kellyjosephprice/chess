class SteppingPiece < Piece
  def moves
    moves = []
    
    move_offsets.each do |rank_offset, file_offset|
      new_pos = @position.dup
      
      new_pos.rank += rank_offset
      new_pos.file += file_offset 
      
      moves << new_pos if valid_move?(new_pos)
    end
    
    moves
  end
end