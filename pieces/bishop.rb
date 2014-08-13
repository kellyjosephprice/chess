# encoding: utf-8

class Bishop < SlidingPiece
  def move_dirs
    DIAGONAL_DIRS
  end
  
  def to_s
    @color == :white ? '♗' : '♝'
  end
end