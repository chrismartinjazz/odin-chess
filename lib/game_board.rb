# frozen_string_literal: true

require 'colorize'
require_relative 'pieces'
require_relative 'position_reader'
require_relative 'board_displayer'

# Holds the pieces and finds legal moves
class GameBoard
  attr_accessor :board

  def initialize(position_text = nil)
    @board = position_text ? PositionReader.new.read_position(position_text) : Array.new(8) { Array.new(8) }
    @board_displayer = BoardDisplayer.new
  end

  # A move has format [<piece>, <origin>, <destination>].
  # Returns the initial occupant of the destination square (nil, or a Piece)
  def move_piece(move)
    destination_square_occupant = @board[move[2][0]][move[2][1]]
    @board[move[2][0]][move[2][1]] = @board[move[1][0]][move[1][1]]
    @board[move[1][0]][move[1][1]] = nil
    destination_square_occupant
  end

  def legal_moves(color, testing_for_check = true)
    legal_moves = []

    (0..7).each do |row_i|
      (0..7).each do |col_i|
        next if @board[row_i][col_i].nil?

        next unless @board[row_i][col_i].color == color

        piece = @board[row_i][col_i]
        legal_moves += if piece.is_a?(Pawn)
                         find_pawn_moves(piece, [row_i, col_i], testing_for_check)
                       else
                         find_moves(piece, [row_i, col_i], testing_for_check)
                       end
      end
    end
    legal_moves
  end

  def find_moves(piece, start, testing_for_check)
    moves = []
    king_position = testing_for_check ? find_king(piece.color) : nil
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
          move = [piece.to_s, start, finish_sq]
          moves.push(move) unless testing_for_check && test_for_check?(move)
          next
        # If it is occupied by an opposing piece, we can capture it, add to legal moves
        elsif finish_occupant.color != piece.color
          move = [piece.to_s, start, finish_sq]
          moves.push(move) unless testing_for_check && test_for_check?(move)
        end
        # If we have reached this line, we have either stored the capture move, or
        # we are looking at a piece of our own color - so go to the next move direction.
        break
      end
    end
    moves
  end

  def find_pawn_moves(pawn, start, testing_for_check)
    pawn_moves = []
    max_move = (pawn.color == 'W' && start[0] == 6) || (pawn.color == 'B' && start[0] == 1) ? 2 : 1
    # For each possible movement (not capturing)
    step = pawn.step_pair_movement
    # Up to as many squares as it can travel
    (1..max_move).each do |squares|
      # Locate the finishing square
      finish_sq = [start[0] + (step[0] * squares), start[1]]
      # Store the occupant of the finish square
      finish_occupant = @board[finish_sq[0]][finish_sq[1]]
      # If it is empty, we can move there - store it and continue.
      break unless finish_occupant.nil?

      pawn_move = [pawn.to_s, start, finish_sq]
      pawn_moves.push(pawn_move) unless testing_for_check && test_for_check?(pawn_move)
      next
      # Otherwise, break.
    end
    # For each possible capture
    pawn.step_pairs_capture.each do |step|
      finish_sq = [start[0] + step[0], start[1] + step[1]]
      # Go to the next move direction if it is off the board
      break unless finish_sq[0].between?(0, 7) && finish_sq[1].between?(0, 7)

      # Store the occupant of the finish square.
      # Go to next move direction unless it is an opposing piece.
      finish_occupant = @board[finish_sq[0]][finish_sq[1]]
      next if finish_occupant.nil? || finish_occupant.color == pawn.color

      # If it is occupied by an opposing piece, we can capture it, add to legal moves
      pawn_move = [pawn.to_s, start, finish_sq]
      pawn_moves.push(pawn_move) unless testing_for_check && test_for_check?(pawn_move)
    end
    pawn_moves
  end

  def test_for_check?(move)
    player_color = move[0].ord < 97 ? 'W' : 'B'
    # Make the move and test for check
    original_occupant = move_piece(move)
    in_check = in_check?(player_color)
    # Undo the move - reverse it and restore original occupant
    move_piece([move[0], move[2], move[1]])
    @board[move[2][0]][move[2][1]] = original_occupant
    # Return the true or false result
    in_check
  end

  def in_check?(color)
    king_position = find_king(color)
    return false if king_position.nil?

    opponent_color = color == 'W' ? 'B' : 'W'
    opponent_legal_moves = legal_moves(opponent_color, false)
    opponent_legal_moves.each do |move|
      return true if move[2] == king_position
    end
    false
  end

  def find_king(color)
    (0..7).each do |row_i|
      (0..7).each do |col_i|
        return [row_i, col_i] if @board[row_i][col_i].is_a?(King) && @board[row_i][col_i].color == color
      end
    end
    nil
  end

  def display
    @board_displayer.display(@board)
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
# GameBoard.new(one_knight).legal_moves('W')
