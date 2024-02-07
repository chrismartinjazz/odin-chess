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
      w_king_side: true, w_queen_side: true,
      b_king_side: true, b_queen_side: true
    }
    @king_position = nil
  end

  # A move has format [<piece>, <origin>, <destination>].
  # Returns the initial occupant of the destination square (nil, or a Piece)

  # TODO: Change this logic so that the GameBoard stores as an instance variable, all of the legal moves for white and
  # all of the legal moves for black, after each move. Also store the king positions to make calculating the legal moves
  # quicker.
  def move_piece(move, testing_for_check: false)
    update_can_castle(move[1]) unless testing_for_check
    castle(move) if castling?(move) && !testing_for_check
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
    original_occupant = move_piece(move, testing_for_check: true)
    @king_position = find_king(player_color) if move[0].upcase == 'K'
    in_check = in_check?(player_color)
    # Undo the move - reverse it and restore original occupant
    move_piece([move[0], move[2], move[1]], testing_for_check: true)
    @king_position = find_king(player_color) if move[0].upcase == 'K'
    @board[move[2][0]][move[2][1]] = original_occupant
    # Return the true or false result
    in_check
  end

  def in_check?(color)
    # king_position = find_king(color)
    return false if @king_position.nil?

    opponent_color = color == 'W' ? 'B' : 'W'
    opponent_legal_moves = legal_moves(opponent_color, active_player: false)
    opponent_legal_moves.each do |move|
      return true if move[2] == @king_position
    end
    false
  end

  def castling?(move)
    move[0].upcase == 'K' && (move[1][1] - move[2][1]).abs == 2
  end

  def castle(move)
    rook_letter = move[0] == 'K' ? 'R' : 'r'
    rook_row = move[1][0]
    rook_start_col = move[2][1] == 2 ? 0 : 7
    rook_end_col = move[2][1] == 2 ? 3 : 5
    move_piece([rook_letter, [rook_row, rook_start_col], [rook_row, rook_end_col]], testing_for_check: false)
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
