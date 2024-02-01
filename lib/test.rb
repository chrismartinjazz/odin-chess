require 'colorize'

piece_map = [
  ['.', 'K', 'Q', 'R', 'B', 'N', 'P', 'k', 'q', 'r', 'b', 'n', 'p'],
  ['  ', '♚ ', '♛ ', '♜ ', '♝ ', '♞ ', '♟︎ ', '♔ ', '♕ ', '♖ ', '♗ ', '♘ ', '♙ ']
]

board = [
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['.', '.', '.', '.', '.', '.', '.', '.'],
  ['N', '.', '.', '.', '.', '.', '.', '.']
]

(0..7).each do |row_i|
  board[row_i].map! { |char| piece_map[1][piece_map[0].index(char) ]}
end

str = ''
# Board

[0, 2, 4, 6].each do |row_pair|
  # First row in pair
  str += "#{8 - row_pair} "
  [0, 2, 4, 6].each do |col_pair|
    str += board[row_pair][col_pair].on_grey
    str += board[row_pair][col_pair + 1].on_magenta
  end
  str += "\n"
  # Second row in pair
  str += "#{8 - row_pair - 1} "
  [0, 2, 4, 6].each do |col_pair|
    str += board[row_pair + 1][col_pair].on_magenta
    str += board[row_pair + 1][col_pair + 1].on_grey
  end
  str += "\n"
end
str += "  a b c d e f g h\n"

print str


# str += '8 '
# str += '♜ '.on_grey
# str += '♞ '.on_magenta
# str += '♝ '.on_grey
# str += '♛ '.on_magenta
# str += '♚ '.on_grey
# str += '♝ '.on_magenta
# str += '♜ '.on_grey
# str += '♞ '.on_magenta
# str += "\n"
# str += '7 '
# str += '♟︎ '.on_magenta
# str += '♟︎ '.on_grey
# str += '♟︎ '.on_magenta
# str += '♟︎ '.on_grey
# str += '♟︎ '.on_magenta
# str += '♟︎ '.on_grey
# str += '♟︎ '.on_magenta
# str += '♟︎ '.on_grey
# str += "\n"
# str += '6 '
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += "\n"
# str += '5 '
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += "\n"
# str += '4 '
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += "\n"
# str += '3 '
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += '  '.on_magenta
# str += '  '.on_grey
# str += "\n"
# str += '2 '
# str += '♙ '.on_grey
# str += '♙ '.on_magenta
# str += '♙ '.on_grey
# str += '♙ '.on_magenta
# str += '♙ '.on_grey
# str += '♙ '.on_magenta
# str += '♙ '.on_grey
# str += '♙ '.on_magenta
# str += "\n"
# str += '1 '
# str += '♖ '.on_magenta
# str += '♘ '.on_grey
# str += '♗ '.on_magenta
# str += '♕ '.on_grey
# str += '♔ '.on_magenta
# str += '♗ '.on_grey
# str += '♘ '.on_magenta
# str += '♖ '.on_grey
# str += "\n"
# str += '  a b c d e f g h'

# puts str
