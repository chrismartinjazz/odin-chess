# frozen_string_literal: true

# Takes a standard chess algebraic move and converts it into an array [<piece>, <origin>, <destination>]
module ConvertTextMoveToArray
  VALIDATION3 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}$/
  VALIDATION4 = /^[KQRNBP]{1}[a-h1-8]{1}[a-h]{1}[1-8]{1}$/
  VALIDATION5 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}[a-h]{1}[1-8]{1}$/
  ALG_MAP_ROW = { nil => nil, '8' => 0, '7' => 1, '6' => 2, '5' => 3, '4' => 4, '3' => 5, '2' => 6, '1' => 7 }.freeze
  ALG_MAP_COL = { nil => nil, 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, 'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7 }.freeze

  def convert_text_move_to_array(move, color)
    return castling(move, color) if castling(move, color)

    return nil unless attempted_move?(move)

    stripped_move = strip_non_algebraic_chars(move)
    stripped_move.prepend('P') unless stripped_move.slice(0).upcase == stripped_move.slice(0)
    return nil unless valid_move?(stripped_move)

    # Move is now 3-5 characters, in format:
    # Piece, (opt. disambiguation 1), (opt. disambiguation 2), destination column, destination row
    alg_to_array(stripped_move, color)
  end

  def castling(move, color)
    king_row = color == 'B' ? 0 : 7
    king_letter = color == 'B' ? 'k' : 'K'
    return [king_letter, [king_row, 4], [king_row, 6]] if %w[O-O 0-0].include?(move)

    return [king_letter, [king_row, 4], [king_row, 2]] if ['O-O-O', '0-0-0'].include?(move)

    false
  end

  def attempted_move?(move)
    attempt = /^[a-hKQRBNP]{1}[a-h1-9x]{1,5}[+#?! ]*?$/
    not_end_with_x = /[^x]$/
    move_no_spaces = move.gsub(/\s+/, '')
    move_no_spaces.match?(attempt) && move_no_spaces.match?(not_end_with_x)
  end

  def strip_non_algebraic_chars(move)
    algebraic = /[a-h1-8KQRBNP]/
    alg_move = ''
    move.each_char { |char| alg_move += char if char.match?(algebraic) }
    alg_move
  end

  def alg_to_array(alg_move, color)
    piece = color == 'W' ? alg_move.slice(0) : alg_move.slice(0).downcase
    origin_square = alg_move_origin_square(alg_move)
    destination_square = alg_move_destination_square(alg_move)
    [piece, origin_square, destination_square]
  end

  def alg_move_destination_square(alg_move)
    dest_row = ALG_MAP_ROW[alg_move.slice(-1)]
    dest_col = ALG_MAP_COL[alg_move.slice(-2)]
    [dest_row, dest_col]
  end

  def alg_move_origin_square(alg_move)
    origin = alg_move[1..-3]
    case origin.length
    when 1
      /[1-8]/.match?(origin) ? orig_row = ALG_MAP_ROW[origin] : orig_col = ALG_MAP_COL[origin]
    when 2
      orig_row = ALG_MAP_ROW[origin.slice(1)]
      orig_col = ALG_MAP_COL[origin.slice(0)]
    end
    [orig_row, orig_col]
  end

  def valid_move?(move)
    case move.length
    when 3
      move.match?(VALIDATION3)
    when 4
      move.match?(VALIDATION4)
    when 5
      move.match?(VALIDATION5)
    else
      false
    end
  end
end
