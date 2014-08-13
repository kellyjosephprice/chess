# encoding: utf-8

class Knight < SteppingPiece  
  def move_offsets
    [
      [ 2,  1], [ 1,  2],
      [-2,  1], [ 1, -2],
      [-2, -1], [-1, -2],
      [ 2, -1], [-1,  2]
    ]
  end
  
  def to_s
    @color == :white ? '♘' : '♞'
  end
end