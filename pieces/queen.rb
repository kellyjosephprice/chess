# encoding: utf-8

class Queen < SlidingPiece
  def move_dirs
    STRAIGHT_DIRS + DIAGONAL_DIRS
  end
  
  def to_s
    @color == :white ? '♕' : '♛'
  end
end