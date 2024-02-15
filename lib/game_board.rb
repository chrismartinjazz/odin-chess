# frozen_string_literal: true

require_relative 'board_displayer'
require_relative 'legal_moves'
require_relative 'pieces'
require_relative 'position_read_write'
require_relative 'test_for_check'
# rubocop:disable Metrics/ClassLength

# Holds the pieces and finds legal moves
class GameBoard
  include LegalMoves
  include TestForCheck

  attr_accessor :board, :fifty_move_counter, :material

  def initialize(position_text = nil)
    @board = position_text ? PositionReadWrite.read_position(position_text) : Array.new(8) { Array.new(8) }
    @can_castle = {
      w_king_side: true, w_queen_side: true,
      b_king_side: true, b_queen_side: true
    }
    @king_position = { 'W' => find_king('W'), 'B' => find_king('B') }
    @material = { 'W' => find_material('W'), 'B' => find_material('B') }
    @en_passant_option = nil
    @fifty_move_counter = 0
  end

  def find_king(color)
    (0..7).each do |row_i|
      (0..7).each do |col_i|
        return [row_i, col_i] if @board[row_i][col_i].is_a?(King) && @board[row_i][col_i].color == color
      end
    end
    nil
  end

  def find_material(color)
    material = []
    # Loop through the board adding to an array every time a piece of correct type appears
    # Sort the array
    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if @board[row_i][col_i].nil? || @board[row_i][col_i].color != color

        material.push(@board[row_i][col_i].to_s)
      end
    end
    material.sort.join
  end

  ## Making moves
  # A move is array in format [<piece>, <origin>, <destination>]
  def move_piece(move, promotion_piece = nil, testing_for_check: false)
    destination_square_occupant = make_move(move[1], move[2])
    update_king_position(move) if move[0].upcase == 'K'
    unless testing_for_check
      update_fifty_move_counter(move, destination_square_occupant)
      en_passant_captured_pawn = handle_special_moves(move, promotion_piece)
      capture = en_passant_captured_pawn || destination_square_occupant || nil
      update_material(move, capture, promotion_piece) if capture || promotion_piece
    end
    en_passant_captured_pawn || destination_square_occupant
  end

  def update_material(move, capture, promotion_piece)
    color = move[0].upcase == move[0] ? 'W' : 'B'
    opponent_color = color == 'W' ? 'B' : 'W'
    @material[opponent_color] = find_material(opponent_color) if capture
    @material[color] = find_material(color) if promotion_piece
  end

  def make_move(origin, destination)
    destination_square_occupant = @board[destination[0]][destination[1]]
    @board[destination[0]][destination[1]] = @board[origin[0]][origin[1]]
    @board[origin[0]][origin[1]] = nil
    destination_square_occupant
  end

  def update_king_position(move)
    move[0] == 'K' ? @king_position['W'] = move[2] : @king_position['B'] = move[2]
  end

  def update_fifty_move_counter(move, destination_square_occupant)
    if move[0].upcase == 'P' || destination_square_occupant
      @fifty_move_counter = 0
    elsif castling?(move)
      nil
    else
      @fifty_move_counter += 1
    end
  end

  def handle_special_moves(move, promotion_piece)
    castle(move) if castling?(move)
    update_can_castle(move[1])
    promote_pawn(move, promotion_piece) if promotion_piece
    en_passant_captured_pawn = en_passant_capture(move)
    @en_passant_options = nil
    pawn_two_square_advance(move)
    en_passant_captured_pawn
  end

  def castle(move)
    rook_letter = move[0] == 'K' ? 'R' : 'r'
    rook_row = move[1][0]
    rook_start_col = move[2][1] == 2 ? 0 : 7
    rook_end_col = move[2][1] == 2 ? 3 : 5
    move_piece([rook_letter, [rook_row, rook_start_col], [rook_row, rook_end_col]], testing_for_check: false)
  end

  def castling?(move)
    move[0].upcase == 'K' && (move[1][1] - move[2][1]).abs == 2
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

    en_passant_remove_pawn(row, col)
  end

  def en_passant_remove_pawn(row, col)
    captured_pawn = @board[row][col]
    @board[row][col] = nil
    captured_pawn
  end

  def display
    BoardDisplayer.display(@board)
  end

  def write_position
    PositionReadWrite.write_position(@board)
  end

  def find_legal_moves(color, active_player: true)
    legal_moves(@board, @king_position, @can_castle, color, active_player:)
  end
end
