# frozen_string_literal: true

# Depends on GameBoard > LegalMoves > Castling

# Checks for legal castling moves on GameBoard's @board.
module LegalCastling
  def legal_castling_moves(color)
    moves = []
    if color == 'W'
      moves += check_castling('W', 'K', 7, 1) if @can_castle[:w_king_side]
      moves += check_castling('W', 'K', 7, -1) if @can_castle[:w_queen_side]
    else
      moves += check_castling('B', 'k', 0, 1) if @can_castle[:b_king_side]
      moves += check_castling('B', 'k', 0, -1) if @can_castle[:b_queen_side]
    end
    moves
  end

  def check_castling(color, king_char, king_row, direction)
    return [] unless path_clear?(king_row, direction)

    return [] unless path_safe?(color, king_char, king_row, direction)

    [king_char, [king_row, 4], [king_row, 4 + (direction * 2)]]
  end

  def path_clear?(king_row, direction)
    @board[king_row][4 + (direction * 1)].nil? && @board[king_row][4 + (direction * 2)].nil?
  end

  def path_safe?(color, king_char, king_row, direction)
    return false if in_check?(color) ||
                    test_for_check?([king_char, [king_row, 4], [king_row, 4 + (direction * 1)]]).nil? ||
                    test_for_check?([king_char, [king_row, 4], [king_row, 4 + (direction * 2)]]).nil?

    true
  end
end
