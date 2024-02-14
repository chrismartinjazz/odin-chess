# frozen_string_literal: true

# Tests if a given move will put the player in check.
module TestForCheck
  def test_for_check?(move)
    player_color = move[0].upcase == move[0] ? 'W' : 'B'
    # Make the move and test for check, storing the original occupant to undo move later.
    original_occupant = move_piece(move, testing_for_check: true)
    in_check = in_check?(player_color)
    undo_move(player_color, move, original_occupant)
    in_check
  end

  def in_check?(color)
    return false if @king_position[color].nil?

    opponent_color = color == 'W' ? 'B' : 'W'
    opponent_legal_moves = find_legal_moves(opponent_color, active_player: false)
    opponent_legal_moves.each do |move|
      return true if move[2] == @king_position[color]
    end
    false
  end

  def undo_move(_player_color, move, original_occupant)
    move_piece([move[0], move[2], move[1]], testing_for_check: true)
    @board[move[2][0]][move[2][1]] = original_occupant
  end
end
