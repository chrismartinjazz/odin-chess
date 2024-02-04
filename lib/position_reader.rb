# frozen_string_literal: true

require_relative 'pieces'

# Reads a position from a text string and generates a 2D array board of pieces, nil for empty squares.
class PositionReader
  def read_position(position_text)
    new_position = []
    (0..7).each do |row|
      new_position.push(position_text[row].split('').map { |char| char_to_piece(char) })
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
end
