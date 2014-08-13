# encoding: utf-8

class Array
  def rank
    self.first
  end
  
  def file
    self.last
  end
  
  def rank= rank
    self[0] = rank
  end
  
  def file= file
    self[1] = file
  end
  
  def pgn 
    "#{ ('a'..'h').to_a[file] }#{ rank + 1 }"
  end
end

class NilClass
  def to_s
    ' '
  end
end

class Piece
  attr_reader :color, :position
  attr_writer :board
  
  def initialize(color, pos, board)
    @color = color
    @position = pos
    @board = board
  end
  
  def dup
    self.class.new(@color, @position.dup, nil)
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

class Rook < SlidingPiece
  def move_dirs
    STRAIGHT_DIRS
  end 
  
  def to_s
    @color == :white ? '♖' : '♜'
  end
end

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

class Bishop < SlidingPiece
  def move_dirs
    DIAGONAL_DIRS
  end
  
  def to_s
    @color == :white ? '♗' : '♝'
  end
end

class Queen < SlidingPiece
  def move_dirs
    STRAIGHT_DIRS + DIAGONAL_DIRS
  end
  
  def to_s
    @color == :white ? '♕' : '♛'
  end
end

class King < SteppingPiece
  def move_offsets
    [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]
  end
  
  def to_s
   @color == :white ? '♔' : '♚'
  end
end

class Pawn < Piece  
  def moves
    moves = []
    
    moves << [1, 0]
    moves.concat(attacks)
    moves << [2, 0] if can_jump?
    
    moves.map { |m| apply_offset(m) }
  end
  
  def to_s
    @color == :white ? '♙' : '♟'
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
  
  def can_jump?
    return false if @color == :white && @position.rank != 1
    return false if @color == :black && @position.rank != 6
    
    clear = [[1, 0], [2, 0]].all? do |offset|
      @board[apply_offset(offset)].nil?
    end 
  end
end