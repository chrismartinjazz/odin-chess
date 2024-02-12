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
        legal_moves_list += find_moves_for_piece(piece, [row_i, col_i], active_player)
      end
    end
    legal_moves_list += legal_castling_moves(board, king_position, can_castle, color) if active_player
    legal_moves_list
  end

  def find_moves_for_piece(piece, position, active_player)
    if piece.is_a?(Pawn)
      find_pawn_moves(piece, position, active_player)
    else
      find_moves(piece, position, active_player)
    end
  end

  def find_moves(piece, start, active_player)
    moves = []
    # For each direction the piece can move
    piece.directions_of_movement.each do |direction|
      # Up to as many squares as it can travel
      (1..piece.max_move).each do |squares|
        # Locate the finishing square
        finish_sq = [start[0] + (direction[0] * squares), start[1] + (direction[1] * squares)]
        # Go to the next move direction if it is off the board
        break unless finish_sq[0].between?(0, 7) && finish_sq[1].between?(0, 7)

        # Store the occupant of the finish square
        finish_occupant = board[finish_sq[0]][finish_sq[1]]
        # If it is empty, we can move there - store it and continue.
        if finish_occupant.nil?
          add_move(moves, piece, start, finish_sq, active_player)
          next
        end
        # If it is occupied by an opposing piece, we can capture it, add to legal moves
        add_move(moves, piece, start, finish_sq, active_player) if finish_occupant.color != piece.color
        # If we have reached this line, we have either stored the capture move, or
        # we are looking at a piece of our own color - so go to the next move direction.
        break
      end
    end
    moves
  end

  def find_pawn_moves(pawn, start, active_player)
    pawn_moves = []
    max_move = (pawn.color == 'W' && start[0] == 6) || (pawn.color == 'B' && start[0] == 1) ? 2 : 1
    # For each possible movement (not capturing)
    direction = pawn.direction_of_movement
    # Up to as many squares as it can travel
    (1..max_move).each do |squares|
      # Locate the finishing square
      finish_sq = [start[0] + (direction[0] * squares), start[1]]
      # Store the occupant of the finish square
      finish_occupant = board[finish_sq[0]][finish_sq[1]]
      # If it is empty, we can move there - store it and continue.
      break unless finish_occupant.nil?

      add_move(pawn_moves, pawn, start, finish_sq, active_player)
      next
      # Otherwise, break.
    end
    # For each possible capture
    pawn.directions_of_capture.each do |direction|
      finish_sq = [start[0] + direction[0], start[1] + direction[1]]
      # Go to the next move direction if it is off the board
      break unless finish_sq[0].between?(0, 7) && finish_sq[1].between?(0, 7)

      # Store the occupant of the finish square.
      # Go to next move direction unless it is an opposing piece or en_passant_option.
      finish_occupant = board[finish_sq[0]][finish_sq[1]]
      next if (finish_occupant.nil? || finish_occupant.color == pawn.color) && (finish_sq != @en_passant_option)

      # If it is occupied by an opposing piece, or an en_passant_option we can capture it, add to legal moves
      add_move(pawn_moves, pawn, start, finish_sq, active_player)
    end
    pawn_moves
  end

  def add_move(moves, piece, start, finish_sq, active_player)
    move = [piece.to_s, start, finish_sq]
    moves.push(move) unless active_player && test_for_check?(move)
  end
end

# rubocop:enable Metrics/MethodLength
