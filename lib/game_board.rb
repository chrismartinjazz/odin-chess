# frozen_string_literal: true

require_relative 'Pieces'

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

  def move(move_start, move_end)
    board[move_end[0]][move_end[1]] = board[move_start[0]][move_start[1]]
    board[move_start[0]][move_start[1]] = nil
  end

  def legal_moves
    legal_moves = []

    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if board[row_i][col_i].nil?

        piece = board[row_i][col_i]
        legal_moves.push(find_moves(piece, [row_i, col_i]))
      end
    end
    legal_moves
  end

  def find_moves(piece, start)
    piece.move_i.each do |move|
      piece.max_move.times do |squares|
        finish = [start[0] + (move[0] * squares), start[1] + (move[1] * squares)]
        # TODO continue this tomorrow
      end
    end
    #.Init legal moves array
    #.For each square
    #.  If nil, continue
    #.  If it is not nil, identify it
    #   For each move_i of that piece
    #     For each from 1 to max_move
    #       Inspect the square.
    #       If it is vacant, it can move there:
    #         add to the list of legal moves
    #       Else if it is occupied by an enemy piece, it can capture there:
    #         add to the list of legal moves and exit loop
    #       Else if it is occupied by a friendly piece or it is off the board:
    #         Exit loop
    #       End if
    #     End For
    #   End For
  end
end
