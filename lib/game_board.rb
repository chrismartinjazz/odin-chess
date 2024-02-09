# frozen_string_literal: true

require 'colorize'
require_relative 'pieces'
require_relative 'position_read_write'
require_relative 'board_displayer'
require_relative 'legal_moves'

# Holds the pieces and finds legal moves
class GameBoard
  include LegalMoves

  attr_accessor :board

  def initialize(position_text = nil)
    @position_read_write = PositionReadWrite.new
    @board = position_text ? @position_read_write.read_position(position_text) : Array.new(8) { Array.new(8) }
    @board_displayer = BoardDisplayer.new
    @can_castle = {
      w_king_side: true, w_queen_side: true,
      b_king_side: true, b_queen_side: true
    }
    @king_position = nil
    @en_passant_option = nil
  end

  # A move has format [<piece>, <origin>, <destination>].
  # Returns the initial occupant of the destination square (nil, or a Piece)
  def move_piece(move, testing_for_check: false)
    destination_square_occupant = @board[move[2][0]][move[2][1]]
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil

    if testing_for_check == false
      castle(move) if castling?(move)
      update_can_castle(move[1])
      promotion_piece = promote_pawn(move, ask_promotion_piece) if pawn_promoting?(move)
      en_passant_captured_pawn = en_passant_capture(move)
      @en_passant_options = nil
      pawn_two_square_advance(move)
    end

    en_passant_captured_pawn || promotion_piece || destination_square_occupant
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

  def pawn_promoting?(move)
    move[0].upcase == 'P' && ((move[2][0]).zero? || move[2][0] == 7)
  end

  def ask_promotion_piece
    puts 'Promote to Q - Queen : R - Rook : B - Bishop : N - Knight'
    options = %w[Q R B N]
    input = ''
    until options.include?(input)
      print '>> '
      input = gets.chomp.strip.upcase.slice(0)
    end
    input
  end

  def promote_pawn(move, promotion_piece)
    color = move[0] == 'P' ? 'W' : 'B'
    map = {
      'Q' => Queen.new(color),
      'R' => Rook.new(color),
      'B' => Bishop.new(color),
      'N' => Knight.new(color)
    }
    @board[move[2][0]][move[2][1]] = map[promotion_piece]
  end

  def pawn_two_square_advance(move)
    return unless move[0].upcase == 'P' && (move[1][0] - move[2][0]).abs == 2

    @en_passant_option = [move[1][0] == 1 ? 2 : 6, move[1][1]]
  end

  def en_passant_capture(move)
    return nil unless move[0].upcase == 'P' && (move[2] == @en_passant_option)

    direction = move[2][1] - move[1][1]
    row = move[1][0]
    col = move[1][1] + direction

    captured_pawn = @board[row][col]
    @board[row][col] = nil
    captured_pawn
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

  def write_position
    @position_read_write.write_position(@board)
  end
end
