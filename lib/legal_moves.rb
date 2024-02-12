# frozen_string_literal: true

require_relative 'legal_castling'

# Depends on GameBoard class, specifically the board instance variable.

# rubocop:disable Metrics/MethodLength

# Finds legal moves in the position.
module LegalMoves
  include LegalCastling

  def legal_moves(board, king_position, can_castle, color, active_player: true)
    legal_moves_list = []

    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if board[row_i][col_i].nil?

        next unless board[row_i][col_i].color == color

        piece = board[row_i][col_i]
        origin = [[row_i], [col_i]]
        legal_moves_list += find_moves_for_piece(board, piece, origin, active_player)
      end
    end
    legal_moves_list += legal_castling_moves(board, king_position, can_castle, color) if active_player
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

  def find_moves(board, piece, origin, active_player)
    moves = []
    piece.directions_of_movement.each do |direction|
      (1..piece.max_move).each do |squares|
        destination = locate_destination_square(origin, direction, squares)
        break unless destination_on_board?(destination)

        destination_sq_occupant = board[destination[0]][destination[1]]
        # If it is empty, we can move there - store it and continue.
        if destination_sq_occupant.nil?
          add_move(moves, piece, origin, destination, active_player)
          next
        end
        # If it is occupied by an opposing piece, we can capture it, add to legal moves
        add_move(moves, piece, origin, destination, active_player) if destination_sq_occupant.color != piece.color
        # If we have reached this line, we have either stored the capture move, or
        # we are looking at a piece of our own color - so go to the next move direction.
        break
      end
    end
    moves
  end

  def find_pawn_moves(pawn, origin, active_player)
    pawn_moves = []
    # vertical_pawn_moves
    max_move = pawn_on_home_row?(pawn, origin) ? 2 : 1
    direction = pawn.direction_of_movement
    (1..max_move).each do |squares|
      destination = locate_destination_square(origin, direction, squares)
      destination_sq_occupant = board[destination[0]][destination[1]]
      # If it is empty, we can move there - store it and continue.
      break unless destination_sq_occupant.nil?

      add_move(pawn_moves, pawn, origin, destination, active_player)
      next
      # Otherwise, break.
    end
    # capturing_pawn_moves
    pawn.directions_of_capture.each do |direction|
      destination = [origin[0] + direction[0], origin[1] + direction[1]]
      # Go to the next move direction if it is off the board
      break unless destination[0].between?(0, 7) && destination[1].between?(0, 7)

      # Store the occupant of the destination square.
      # Go to next move direction unless it is an opposing piece or en_passant_option.
      destination_sq_occupant = board[destination[0]][destination[1]]
      if (destination_sq_occupant.nil? || destination_sq_occupant.color == pawn.color) && (destination != @en_passant_option)
        next
      end

      # If it is occupied by an opposing piece, or an en_passant_option we can capture it, add to legal moves
      add_move(pawn_moves, pawn, origin, destination, active_player)
    end
    pawn_moves
  end

  def locate_destination_square(origin, direction, squares)
    [origin[0] + (direction[0] * squares), origin[1] + (direction[1] * squares)]
  end

  def destination_on_board?(destination)
    destination[0].between?(0, 7) && destination[1].between?(0, 7)
  end

  def pawn_on_home_row?(pawn, origin)
    (pawn.color == 'W' && origin[0] == 6) || (pawn.color == 'B' && origin[0] == 1)
  end

  def add_move(moves, piece, origin, destination, active_player)
    move = [piece.to_s, origin, destination]
    moves.push(move) unless active_player && test_for_check?(move)
  end
end

# rubocop:enable Metrics/MethodLength
