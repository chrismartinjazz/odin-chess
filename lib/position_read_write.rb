# frozen_string_literal: true

require_relative 'pieces'

# Reads a position from a text string and generates a 2D array board of pieces, nil for empty squares.
module PositionReadWrite
  PIECE_MAP = {
    '.' => nil,
    'P' => Pawn,
    'N' => Knight,
    'B' => Bishop,
    'R' => Rook,
    'Q' => Queen,
    'K' => King
  }.freeze

  extend self

  def read_position(position_text)
    new_position = []
    (0..7).each do |row|
      new_position.push(position_text[row].chars.map { |char| char_to_piece(char) })
    end
    new_position
  end

  def write_position(board)
    output = []
    (0..7).each do |row|
      row_str = ''
      (0..7).each do |col|
        row_str += piece_to_char(board[row][col])
      end
      output << row_str
    end
    output
  end

  private

  def char_to_piece(char)
    piece_type = char.upcase
    color = piece_type == char ? 'W' : 'B'
    piece_class = PIECE_MAP[piece_type]
    piece_class&.new(color)
  end

  def piece_to_char(piece)
    piece.nil? ? '.' : piece.to_s
  end
end
