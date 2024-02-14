# frozen_string_literal: true

require 'colorize'

# Converts a board with piece objects into a colorized string with icons.
module BoardDisplayer
  ICON_MAP = { 'K' => '♚ ', 'Q' => '♛ ', 'R' => '♜ ', 'B' => '♝ ', 'N' => '♞ ', 'P' => '♟︎ ',
               'k' => '♔ ', 'q' => '♕ ', 'r' => '♖ ', 'b' => '♗ ', 'n' => '♘ ', 'p' => '♙ ' }.freeze

  extend self

  def display(board, string = '')
    board_icons = convert_board_to_icons(board)
    # For each pair of rows
    [0, 2, 4, 6].each do |row_pair_i|
      string += colorize_row(board_icons, row_pair_i, 0)
      string += colorize_row(board_icons, row_pair_i, 1)
    end
    "#{string}  a b c d e f g h\n"
  end

  private

  def convert_board_to_icons(board)
    board_icons = []
    (0..7).each do |row_i|
      new_row = board[row_i].map { |elem| elem.nil? ? '  ' : ICON_MAP[elem.to_s] }
      board_icons << new_row
    end
    board_icons
  end

  def colorize_row(board_icons, row_pair_i, offset = 0)
    string = "#{8 - row_pair_i - offset} "
    [0, 2, 4, 6].each do |col_i|
      string += if offset.zero?
                  colorize_even_row_squares(board_icons, row_pair_i, col_i)
                else
                  colorize_odd_row_squares(board_icons, row_pair_i, col_i)
                end
    end
    "#{string}\n"
  end

  def colorize_even_row_squares(board_icons, row_pair_i, col_i)
    "#{board_icons[row_pair_i][col_i].on_grey}#{board_icons[row_pair_i][col_i + 1].on_magenta}"
  end

  def colorize_odd_row_squares(board_icons, row_pair_i, col_i)
    "#{board_icons[row_pair_i + 1][col_i].on_magenta}#{board_icons[row_pair_i + 1][col_i + 1].on_grey}"
  end
end
