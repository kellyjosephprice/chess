# encoding: utf-8

class Rook < SlidingPiece
  def move_dirs
    STRAIGHT_DIRS
  end 
  
  def to_s
    @color == :white ? '♖' : '♜'
  end
end