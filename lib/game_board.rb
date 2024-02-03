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
    new_position = []
    (0..7).each do |row|
      new_position.push(pos[row].split('').map { |char| char_to_piece(char) })
    end
    new_position
  end

  def char_to_piece(char)
    color = char.ord < 97 ? 'W' : 'B'
    case char
    when '.'
      nil
    when 'N', 'n'
      Knight.new(color)
    when 'R', 'r'
      Rook.new(color)
    when 'B', 'b'
      Bishop.new(color)
    when 'Q', 'q'
      Queen.new(color)
    when 'K', 'k'
      King.new(color)
    when 'P', 'p'
      Pawn.new(color)
    end
  end

  # A move has format [<piece>, <origin>, <destination>]
  def move_piece(move)
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil
  end

  def legal_moves(color)
    legal_moves = []

    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if @board[row_i][col_i].nil?

        next unless @board[row_i][col_i].color == color

        piece = @board[row_i][col_i]
        if piece.is_a?(Pawn)
          legal_moves += (find_pawn_moves(piece, [row_i, col_i]))
        else
          legal_moves += (find_moves(piece, [row_i, col_i]))
        end
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

  def find_pawn_moves(pawn, start)
    pawn_moves = []
    max_move = if (pawn.color == 'W' && start[0] == 6) || (pawn.color == 'B' && start[0] == 1)
                 2
               else
                 1
               end
    # For each possible movement (not capturing)
    step = pawn.step_pair_movement
    # Up to as many squares as it can travel
    (1..max_move).each do |squares|
      # Locate the finishing square
      finish_sq = [start[0] + (step[0] * squares), start[1]]
      # Store the occupant of the finish square
      finish_occupant = @board[finish_sq[0]][finish_sq[1]]
      # If it is empty, we can move there - store it and continue.
      if finish_occupant.nil?
        pawn_moves.push([pawn.to_s, start, finish_sq])
        next
      # Otherwise, break.
      else
        break
      end
    end
    # For each possible capture
    pawn.step_pairs_capture.each do |step|
      finish_sq = [start[0] + step[0], start[1] + step[1]]
      # Go to the next move direction if it is off the board
      break unless finish_sq[0].between?(0, 7) && finish_sq[1].between?(0, 7)

      # Store the occupant of the finish square
      finish_occupant = @board[finish_sq[0]][finish_sq[1]]
      next if finish_occupant.nil?
      # If it is occupied by an opposing piece, we can capture it, add to legal moves
      pawn_moves.push([pawn.to_s, start, finish_sq]) if finish_occupant.color != pawn.color
    end
    pawn_moves
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

# main_pieces = %w[
#   rnbqkbnr
#   ........
#   ........
#   ........
#   ........
#   ........
#   ........
#   RNBQKBNR
# ]
# p GameBoard.new(main_pieces).legal_moves('B')
# p GameBoard.new(main_pieces).legal_moves('W')
