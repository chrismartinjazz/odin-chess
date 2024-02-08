# frozen_string_literal: true

class MoveConverter
  def convert(move, color)
    return check_castling(move, color) if check_castling(move, color)

    return nil unless attempted_move?(move)

    # Strip non-algebraic move characters,
    # prepend P if first letter in not capitalized,
    # then check it has valid characters in each position and is the right length.
    alg_move = strip_chars(move)
    return nil if alg_move == ''

    alg_move.prepend('P') unless alg_move.slice(0).ord.between?(65, 90)
    return nil unless valid_move?(alg_move)

    # Move is now 3-5 characters, in format:
    # Piece, (opt. disambiguation 1, opt. disambiguation 2), destination column, destination row
    alg_move_to_array(alg_move, color)
  end

  def check_castling(move, color)
    king_row = color == 'B' ? 0 : 7
    king_letter = color == 'B' ? 'k' : 'K'
    return [king_letter, [king_row, 4], [king_row, 6]] if %w[O-O 0-0].include?(move)

    return [king_letter, [king_row, 4], [king_row, 2]] if ['O-O-O', '0-0-0'].include?(move)

    false
  end

  def attempted_move?(move)
    attempt = /^[a-hKQRBNP]{1}[a-h1-9x]{1,5}[+#?! ]*?$/
    not_end_with_x = /[^x]$/

    move.match?(attempt) && move.match?(not_end_with_x)
  end

  def strip_chars(move)
    algebraic = /[a-h1-8KQRBNP]/
    alg_move = ''
    move.each_char { |char| alg_move += char if char.match?(algebraic) }
    alg_move
  end

  def alg_move_to_array(alg_move, color)
    alg_map = [
      [nil, '8', '7', '6', '5', '4', '3', '2', '1', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
      [nil, 0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 6, 7]
    ]

    dest_row = alg_map[1][alg_map[0].index(alg_move.slice(-1))]
    dest_col = alg_map[1][alg_map[0].index(alg_move.slice(-2))]

    origin = alg_move[1..-3]
    case origin.length
    when 1
      if /[1-8]/.match?(origin)
        orig_row = alg_map[1][alg_map[0].index(origin.slice(0))]
      else
        orig_col = alg_map[1][alg_map[0].index(origin.slice(0))]
      end
    when 2
      orig_row = alg_map[1][alg_map[0].index(origin.slice(1))]
      orig_col = alg_map[1][alg_map[0].index(origin.slice(0))]
    end

    move_array = [alg_move.slice(0), [orig_row, orig_col], [dest_row, dest_col]]
    move_array[0].downcase! if color == 'B'
    move_array
  end

  def valid_move?(move)
    validation_length_3 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}$/
    validation_length_4 = /^[KQRNBP]{1}[a-h1-8]{1}[a-h]{1}[1-8]{1}$/
    validation_length_5 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}[a-h]{1}[1-8]{1}$/

    case move.length
    when 3
      move.match?(validation_length_3)
    when 4
      move.match?(validation_length_4)
    when 5
      move.match?(validation_length_5)
    else
      false
    end
  end
end
