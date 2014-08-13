# encoding: utf-8

class Pawn < Piece
  attr_accessor :in_passing
  alias_method :in_passing?, :in_passing
  
  def initialize(*args)
    super
    @promoting = false
    @in_passing = false
  end
  
  def moves
    moves = []
    
    moves << [1, 0] if @board[apply_offset([1, 0])].nil?
    moves.concat(attacks)
    moves << en_passant
    moves << [2, 0] if can_jump?
    
    moves.compact.map { |m| apply_offset(m) }
  end
  
  def to_s
    @color == :white ? '♙' : '♟'
  end
  
  def move(position)
    @in_passing = (position.rank - @position.rank).abs == 2
    
    old_position = @position
    en_passanting = position.file != @position.file && @board[position].nil?
    
    super
    
    if en_passanting
      @board[apply_offset([-1, 0])] = nil
    end
    
    @promoting = [0, 7].include? @position.rank
  end
  
  def promoting?
    @promoting
  end
  
  private
  
  def apply_offset offset
    if @color == :white
      [@position.rank + offset.rank, @position.file + offset.file]
    else
      [@position.rank - offset.rank, @position.file - offset.file]
    end
  end
  
  def attacks 
    [[1, -1], [1, 1]].select do |offset|
      offset_tile = @board[apply_offset(offset)]
      
      !offset_tile.nil? && offset_tile.color != @color
    end 
  end
  
  def en_passant
    pawns = @board.pieces_by_type(Pawn, @board.opposing_color(@color))
    
    attackable = pawns.find do |pawn|
      pawn.in_passing? && left_or_right(pawn.position)
    end
    
    [1, attackable.position.file - @position.file] if attackable
  end
  
  def left_or_right position
    position.rank == @position.rank && 1 == (@position.file - position.file).abs
  end
  
  def can_jump?
    return false if @moved
    
    clear = [[1, 0], [2, 0]].all? do |offset|
      @board[apply_offset(offset)].nil?
    end 
  end
end