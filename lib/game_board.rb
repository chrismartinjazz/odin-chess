# frozen_string_literal: true

require 'colorize'

require_relative 'pieces'

# Holds the pieces and finds legal moves
class GameBoard
  attr_accessor :board

  def initialize(position = nil)
    @board = position ? read_position(position) : Array.new(8) { Array.new(8) }
  end

  def read_position(pos)
    new_pos = []
    (0..7).each do |row|
      new_pos.push(pos[row].split('').map { |char| char_to_piece(char) })
    end
    new_pos
  end

  def char_to_piece(char)
    case char
    when '.'
      nil
    when 'N'
      Knight.new('white')
    end
  end

  # A move has format [<piece>, <origin>, <destination>]
  def move_piece(move)
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil
  end

  def legal_moves
    legal_moves = []

    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if @board[row_i][col_i].nil?

        piece = @board[row_i][col_i]
        legal_moves += (find_moves(piece, [row_i, col_i]))
      end
    end
    legal_moves
  end

  def find_moves(piece, start)
    moves = []
    # For each direction the piece can move
    piece.step_pairs.each do |step|
      # Up to as many squares as it can travel
      (1..piece.max_move).each do |squares|
        # Locate the finishing square
        finish_sq = [start[0] + (step[0] * squares), start[1] + (step[1] * squares)]
        # Go to the next move direction if it is off the board
        break unless finish_sq[0].between?(0, 7) && finish_sq[1].between?(0, 7)

        # Store the occupant of the finish square
        finish_occupant = @board[finish_sq[0]][finish_sq[1]]
        # If it is empty, we can move there - store it and continue.
        if finish_occupant.nil?
          moves.push([piece.to_s, start, finish_sq])
          next
        # If it is occupied by an opposing piece, we can capture it, add to legal moves
        elsif finish_occupant.color != piece.color
          moves.push([piece.to_s, start, finish_sq])
        end
        # If we have reached this line, we have either stored the capture move, or
        # we are looking at a piece of our own color - so go to the next move direction.
        break
      end
    end
    moves
  end

  def display
    board_copy = []
    (0..7).each do |row_i|
      new_row = @board[row_i].map { |elem| elem.nil? ? '.' : elem.to_s }
      board_copy << new_row
    end

    piece_map = [
      ['.', 'K', 'Q', 'R', 'B', 'N', 'P', 'k', 'q', 'r', 'b', 'n', 'p'],
      ['  ', '♚ ', '♛ ', '♜ ', '♝ ', '♞ ', '♟︎ ', '♔ ', '♕ ', '♖ ', '♗ ', '♘ ', '♙ ']
    ]

    (0..7).each do |row_i|
      board_copy[row_i].map! { |char| piece_map[1][piece_map[0].index(char) ]}
    end

    str = ''
    [0, 2, 4, 6].each do |row_pair|
      # First row in pair
      str += "#{8 - row_pair} "
      [0, 2, 4, 6].each do |col_pair|
        str += board_copy[row_pair][col_pair].on_grey
        str += board_copy[row_pair][col_pair + 1].on_magenta
      end
      str += "\n"
      # Second row in pair
      str += "#{8 - row_pair - 1} "
      [0, 2, 4, 6].each do |col_pair|
        str += board_copy[row_pair + 1][col_pair].on_magenta
        str += board_copy[row_pair + 1][col_pair + 1].on_grey
      end
      str += "\n"
    end
    str + "  a b c d e f g h\n"
  end
end

# one_knight = %w[
#     ........
#     ........
#     ........
#     ........
#     ........
#     ........
#     ........
#     N.......
#   ]
# GameBoard.new(one_knight).move_piece(['N', [7, 0], [5, 1]])
# GameBoard.display
