# frozen_string_literal: true

# Depends on GameBoard > LegalMoves > Castling

# Checks for legal castling moves on GameBoard's board.
module LegalCastling
  def legal_castling_moves(board, king_position, can_castle, color)
    moves = []
    if color == 'W'
      moves << check_castling(board, king_position, 'W', 'K', 7, 1) if can_castle[:w_king_side]
      moves << check_castling(board, king_position, 'W', 'K', 7, -1) if can_castle[:w_queen_side]
    else
      moves << check_castling(board, king_position, 'B', 'k', 0, 1) if can_castle[:b_king_side]
      moves << check_castling(board, king_position, 'B', 'k', 0, -1) if can_castle[:b_queen_side]
    end

    moves.compact
  end

  def check_castling(board, king_position, color, king_char, king_row, direction)
    return nil unless king_position[color] == [king_row, 4]

    return nil unless path_clear?(board, king_row, direction)

    return nil unless path_safe?(board, color, king_char, king_row, direction)

    [king_char, [king_row, 4], [king_row, 4 + (direction * 2)]]
  end

  def path_clear?(board, king_row, direction)
    return false if direction == -1 && !board[king_row][1].nil?

    board[king_row][4 + (direction * 1)].nil? && board[king_row][4 + (direction * 2)].nil?
  end

  def path_safe?(_board, color, king_char, king_row, direction)
    return false if in_check?(color) ||
                    test_for_check?([king_char, [king_row, 4], [king_row, 4 + (direction * 1)]]) ||
                    test_for_check?([king_char, [king_row, 4], [king_row, 4 + (direction * 2)]])

    true
  end
end
