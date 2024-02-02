test = "Nxb6++"
out = ''
ALGEBRAIC = /[a-h1-8KQRBNP]/

test.each_char { |char| out += char if char.match?(ALGEBRAIC) }
puts out

# require 'colorize'

# piece_map = [
#   ['.', 'K', 'Q', 'R', 'B', 'N', 'P', 'k', 'q', 'r', 'b', 'n', 'p'],
#   ['  ', '♚ ', '♛ ', '♜ ', '♝ ', '♞ ', '♟︎ ', '♔ ', '♕ ', '♖ ', '♗ ', '♘ ', '♙ ']
# ]

# board = [
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['.', '.', '.', '.', '.', '.', '.', '.'],
#   ['N', '.', '.', '.', '.', '.', '.', '.']
# ]

# (0..7).each do |row_i|
#   board[row_i].map! { |char| piece_map[1][piece_map[0].index(char) ]}
# end

# str = ''
# # Board

# [0, 2, 4, 6].each do |row_pair|
#   # First row in pair
#   str += "#{8 - row_pair} "
#   [0, 2, 4, 6].each do |col_pair|
#     str += board[row_pair][col_pair].on_grey
#     str += board[row_pair][col_pair + 1].on_magenta
#   end
#   str += "\n"
#   # Second row in pair
#   str += "#{8 - row_pair - 1} "
#   [0, 2, 4, 6].each do |col_pair|
#     str += board[row_pair + 1][col_pair].on_magenta
#     str += board[row_pair + 1][col_pair + 1].on_grey
#   end
#   str += "\n"
# end
# str += "  a b c d e f g h\n"

# print str
