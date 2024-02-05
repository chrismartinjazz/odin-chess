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
    @can_castle = {
      w_king_side: false, w_queen_side: false,
      b_king_side: false, b_queen_side: false
    }
    return unless castling_initial_position?

    @can_castle = {
      w_king_side: true, w_queen_side: true,
      b_king_side: true, b_queen_side: true
    }
  end

  # A move has format [<piece>, <origin>, <destination>].
  # Returns the initial occupant of the destination square (nil, or a Piece)
  def castling_initial_position?
    @board[0, 0].is_a?(Rook) &&
      @board[0, 4].is_a?(King) &&
      @board[0, 7].is_a?(Rook) &&
      @board[7, 0].is_a?(Rook) &&
      @board[7, 4].is_a?(King) &&
      @board[7, 7].is_a?(Rook)
  end

  def move_piece(move, testing_for_check = true)
    update_can_castle(move[1]) unless testing_for_check
    destination_square_occupant = @board[move[2][0]][move[2][1]]
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil
    destination_square_occupant
  end

  def update_can_castle(start_sq)
    case start_sq
    when [0, 4]
      @can_castle[:b_king_side] = false
      @can_castle[:b_queen_side] = false
    when [7, 4]
      @can_castle[:w_king_side] = false
      @can_castle[:w_queen_side] = false
    when [0, 0]
      @can_castle[:b_queen_side] = false
    when [0, 7]
      @can_castle[:b_king_side] = false
    when [7, 0]
      @can_castle[:w_queen_side] = false
    when [7, 7]
      @can_castle[:w_king_side] = false
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
