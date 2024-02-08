# frozen_string_literal: true

require_relative 'pieces'

# Reads a position from a text string and generates a 2D array board of pieces, nil for empty squares.
class PositionReadWrite
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

  def write_position(board)
    # Iterate through board converting back from pieces and nil.
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

  def piece_to_char(piece)
    if piece.nil?
      return '.'
    elsif piece.is_a?(Knight)
      char = 'N'
    elsif piece.is_a?(Bishop)
      char = 'B'
    elsif piece.is_a?(Rook)
      char = 'R'
    elsif piece.is_a?(Queen)
      char = 'Q'
    elsif piece.is_a?(King)
      char = 'K'
    elsif piece.is_a?(Pawn)
      char = 'P'
    end

    char = char.downcase if piece.color == 'B'
    char
  end
end
