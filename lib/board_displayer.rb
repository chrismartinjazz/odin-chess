# frozen_string_literal: true

require 'colorize'

# Converts a board with piece objects into a coloured string.
class BoardDisplayer
  def display(board, string = '')
    # Convert the board to array of piece pictures with spaces for empty square
    board_copy = board_to_strings(board)
    # For each pair of rows
    [0, 2, 4, 6].each do |row_i|
      # First row in pair
      string += row_to_string(board_copy, row_i, 0)
      string += row_to_string(board_copy, row_i, 1)
    end
    "#{string}  a b c d e f g h\n"
  end

  def row_to_string(board_copy, row_i, offset = 0, string = '')
    string += "#{8 - row_i - offset} "
    [0, 2, 4, 6].each do |col_i|
      if offset.zero?
        string += board_copy[row_i][col_i].on_grey
        string += board_copy[row_i][col_i + 1].on_magenta
      else
        string += board_copy[row_i + 1][col_i].on_magenta
        string += board_copy[row_i + 1][col_i + 1].on_grey
      end
    end
    string + "\n"
  end

  # def col_to_string(board_copy, row_i, )

  # end

  def board_to_strings(board)
    piece_map = [
      ['K', 'Q', 'R', 'B', 'N', 'P', 'k', 'q', 'r', 'b', 'n', 'p'],
      ['♚ ', '♛ ', '♜ ', '♝ ', '♞ ', '♟︎ ', '♔ ', '♕ ', '♖ ', '♗ ', '♘ ', '♙ ']
    ]
    board_copy = []
    (0..7).each do |row_i|
      new_row = board[row_i].map { |elem| elem.nil? ? '  ' : piece_map[1][piece_map[0].index(elem.to_s)] }
      board_copy << new_row
    end
    board_copy
  end
end
