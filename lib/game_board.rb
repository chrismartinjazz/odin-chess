# frozen_string_literal: true

require 'colorize'
require_relative 'pieces'
require_relative 'position_reader'
require_relative 'board_displayer'
require_relative 'legal_moves'

# Holds the pieces and finds legal moves
class GameBoard
  include LegalMoves

  attr_accessor :board

  def initialize(position_text = nil)
    @board = position_text ? PositionReader.new.read_position(position_text) : Array.new(8) { Array.new(8) }
    @board_displayer = BoardDisplayer.new
    @castling_permitted = {
      white_king_side: true, white_queen_side: true,
      black_king_side: true, black_queen_side: true
    }
  end

  # A move has format [<piece>, <origin>, <destination>].
  # Returns the initial occupant of the destination square (nil, or a Piece)
  def move_piece(move)
    update_castling_permitted(move[1])
    destination_square_occupant = @board[move[2][0]][move[2][1]]
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil
    destination_square_occupant
  end

  def update_castling_permitted(start_sq)
    case start_sq
    when [0, 4]
      @castling_permitted[:black_king_side] = false
      @castling_permitted[:black_queen_side] = false
    when [7, 4]
      @castling_permitted[:white_king_side] = false
      @castling_permitted[:white_queen_side] = false
    when [0, 0]
      @castling_permitted[:black_queen_side] = false
    when [0, 7]
      @castling_permitted[:black_king_side] = false
    when [7, 0]
      @castling_permitted[:white_queen_side] = false
    when [7, 7]
      @castling_permitted[:white_king_side] = false
    end
  end

  def test_for_check?(move)
    player_color = move[0].ord < 97 ? 'W' : 'B'
    # Make the move and test for check
    original_occupant = move_piece(move)
    in_check = in_check?(player_color)
    # Undo the move - reverse it and restore original occupant
    move_piece([move[0], move[2], move[1]])
    @board[move[2][0]][move[2][1]] = original_occupant
    # Return the true or false result
    in_check
  end

  def in_check?(color)
    king_position = find_king(color)
    return false if king_position.nil?

    opponent_color = color == 'W' ? 'B' : 'W'
    opponent_legal_moves = legal_moves(opponent_color, false)
    opponent_legal_moves.each do |move|
      return true if move[2] == king_position
    end
    false
  end

  def find_king(color)
    (0..7).each do |row_i|
      (0..7).each do |col_i|
        return [row_i, col_i] if @board[row_i][col_i].is_a?(King) && @board[row_i][col_i].color == color
      end
    end
    nil
  end

  def display
    @board_displayer.display(@board)
  end
end
