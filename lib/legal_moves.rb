# frozen_string_literal: true

require_relative 'legal_castling_moves'
require_relative 'test_for_check'

# Finds legal moves in the position.
module LegalMoves
  include LegalCastlingMoves

  def legal_moves(board, king_position, can_castle, color, active_player: true)
    legal_moves_list = []
    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if board[row_i][col_i].nil?

        next unless board[row_i][col_i].color == color

        piece = board[row_i][col_i]
        origin = [row_i, col_i]
        legal_moves_list += find_moves_for_piece(board, piece, origin, active_player)
      end
    end
    if active_player
      legal_moves_list += legal_castling_moves(board, king_position, can_castle,
                                               color)
    end
    legal_moves_list
  end

  def find_moves_for_piece(board, piece, origin, active_player)
    if piece.is_a?(Pawn)
      find_pawn_moves(board, piece, origin,
                      active_player)
    else
      find_moves(board, piece, origin, active_player)
    end
  end

  def find_pawn_moves(board, pawn, origin, active_player)
    pawn_moves = []
    pawn_moves += find_moves(board, pawn, origin, active_player)
    pawn_moves += capturing_pawn_moves(board, pawn, origin, active_player)
    pawn_moves
  end

  def find_moves(board, piece, origin, active_player)
    moves = []
    piece.directions_of_movement.each do |direction|
      explore_direction(moves, direction, board, piece, origin, active_player)
    end
    moves
  end

  def explore_direction(moves, direction, board, piece, origin, active_player)
    max_move = find_max_move(piece, origin)
    (1..max_move).each do |squares|
      destination = locate_destination_square(origin, direction, squares)
      break unless destination_on_board?(destination)

      destination_sq_occupant = board[destination[0]][destination[1]]
      if destination_sq_occupant.nil?
        add_move(moves, piece, origin, destination, active_player)
        next
      end

      if destination_sq_occupant.color != piece.color && !piece.is_a?(Pawn)
        add_move(moves, piece, origin, destination,
                 active_player)
      end
      break
    end
  end

  def capturing_pawn_moves(board, pawn, origin, active_player)
    moves = []
    pawn.directions_of_capture.each do |direction|
      destination = locate_destination_square(origin, direction)
      break unless destination_on_board?(destination)

      destination_sq_occupant = board[destination[0]][destination[1]]
      if (destination_sq_occupant.nil? || destination_sq_occupant.color == pawn.color) && (destination != @en_passant_option)
        next
      end

      add_move(moves, pawn, origin, destination, active_player)
    end
    moves
  end

  def find_max_move(piece, origin)
    piece.is_a?(Pawn) && pawn_on_home_row?(piece, origin) ? 2 : piece.max_move
  end

  def pawn_on_home_row?(pawn, origin)
    (pawn.color == 'W' && origin[0] == 6) || (pawn.color == 'B' && origin[0] == 1)
  end

  def locate_destination_square(origin, direction, squares = 1)
    [origin[0] + (direction[0] * squares), origin[1] + (direction[1] * squares)]
  end

  def destination_on_board?(destination)
    destination[0].between?(0, 7) && destination[1].between?(0, 7)
  end

  def add_move(moves, piece, origin, destination, active_player)
    move = [piece.to_s, origin, destination]
    moves.push(move) unless active_player && test_for_check?(move)
  end
end
