require './pieces'
require 'colorize'

class Board
  attr_reader :board
  
  def initialize(new_game = true)
    @board = Array.new(8) { Array.new(8) }
    
    set_pieces if new_game
  end
  
  def self.in_bounds?(pos)
    pos.all? { |vector| vector.between?(0, 7) }
  end
  
  def [] pos
    @board[pos.rank][pos.file]
  end
  
  def []= pos, piece
    @board[pos.rank][pos.file] = piece
  end 
  
  def to_s(player = :white)
    board = player == :white ? @board.reverse : @board
    
    board.each_with_index.map do |row, rank|
      row_str = player == :white ? "#{8 - rank} " : "#{rank + 1} "
      
      tiles = row.each_with_index.map do |tile, file|
        character = tile.to_s + ' '
        
        if white_tile? [rank, file]
          character = character.on_light_white
        else
          character = character.on_white
        end
      end
      
      row_str + tiles.join("") + "\n"
    end.join("").concat('  ' + ('a'..'h').to_a.join(' '))
  end
  
  def move(color, start_pos, end_pos)
    
    if self[start_pos].color != color
      raise InvalidMoveError.new(
        "Piece at #{ start.pgn } does not belong to #{ @color }.")
    end
    
    piece = self[start_pos]
    
    if piece.nil?
      raise InvalidMoveError.new(
        "There is no piece at #{ start_pos.pgn } to move.")
    elsif !piece.legal_moves.include?(end_pos)
      raise InvalidMoveError.new(
        "Piece at #{ start_pos.pgn } can't move to #{ end_pos.pgn }.")
    end
    
    reset_in_passing
    
    piece.move(end_pos)
  end
  
  def reset_in_passing
    pieces.each do |piece|
      piece.in_passing = false if piece.is_a? Pawn
    end
  end
  
  def promoting?(color)
    pawn = pieces_by_type(Pawn, color).any? { |p| p.promoting? }
  end
  
  def promote(color, promotion)
    pawn = pieces_by_type(Pawn, color).find { |p| p.promoting? }
    
    self[pawn.position] = nil
    self[pawn.position] = promotion.new(color, pawn.position, self)
  end
  
  def in_check?(color)
    king = pieces_by_type(King, color).first
    
    opponents_for_color(color).any? do |opponent|
      opponent.moves.include? king.position
    end
  end
  
  def checkmate?(color)
    return false unless in_check? color
    
    pieces_by_color(color).all? do |piece|
      piece.legal_moves.empty?
    end
  end
  
  def stalemate?(color)
    return false if in_check? color
    
    pieces_by_color(color).all? do |piece|
      piece.legal_moves.empty?
    end
  end
  
  def dup
    duped = Board.new(false)
    
    @board.each_with_index do |row, rank|
      row.each_with_index do |piece, file|
        old_piece = self[[rank, file]]
        
        next if old_piece.nil?
        
        new_piece = old_piece.dup
        
        duped[[rank, file]] = new_piece     
        new_piece.board = duped
      end
    end
    
    duped
  end
  
  def pieces_by_type(type, color)
    pieces_by_color(color).select { |p| p.is_a?(type) }
  end
  
  def pieces_by_color(color)
    pieces.select { |p| p.color == color }
  end
  
  def pieces
    @board.flatten.compact
  end
  
  def opponents_for_color(color)
    pieces_by_color(opposing_color(color))
  end
  
  def opposing_color(color)
    color == :white ? :black : :white
  end
  
  private
  
  def set_pieces
    back_row = [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]
    
    [ [:white, 0, 1], [:black, 7, 6] ].each do |color, rank, pawn_rank|
      back_row.each_with_index do |piece_class, file|
        @board[rank][file] = piece_class.new(color, [rank, file], self)
      end
      
      8.times do |file|
        @board[pawn_rank][file] = Pawn.new(color, [pawn_rank, file], self)
      end
    end
  end  
  
  def white_tile? pos
    pos.rank % 2 == pos.file % 2 
  end
end

class InvalidMoveError < StandardError
end
