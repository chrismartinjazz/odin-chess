# frozen_string_literal: true

# TODO: This should definitely be a module instead - all behaviour, no state - probably two modules.
# rubocop:disable Metrics/ClassLength

# Converts move array [<piece>, <origin>, <destination>] to and from standard algebraic notation
class MoveConverter
  def initialize
    @validation_length3 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}$/
    @validation_length4 = /^[KQRNBP]{1}[a-h1-8]{1}[a-h]{1}[1-8]{1}$/
    @validation_length5 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}[a-h]{1}[1-8]{1}$/
    @alg_map_row = { nil => nil, '8' => 0, '7' => 1, '6' => 2, '5' => 3, '4' => 4, '3' => 5, '2' => 6, '1' => 7 }
    @alg_map_col = { nil => nil, 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, 'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7 }
    @array_map_castling = {
      ['K', [7, 4], [7, 6]] => '0-0',
      ['K', [7, 4], [7, 2]] => '0-0-0',
      ['k', [0, 4], [0, 6]] => '0-0',
      ['k', [0, 4], [0, 2]] => '0-0-0'
    }
  end

  def alg_move_to_array(move, color)
    # First handle castling (e.g. '0-0')
    return alg_check_castling(move, color) if alg_check_castling(move, color)

    # Next handle strings that do not appear to attempt an algebraic move e.g. 'cat'
    return nil unless alg_attempted_move?(move)

    # Strip non-algebraic move characters, and return nil if less than two characters are left
    # (backup check for attempted move)
    alg_move = alg_strip_chars(move)
    return nil if alg_move.length < 2

    # Prepend P if first letter is not capitalized
    alg_move.prepend('P') unless alg_move.slice(0).ord.between?(65, 90)

    # Check the move has valid characters in each position and is the right length.
    return nil unless alg_valid_move?(alg_move)

    # Move is now 3-5 characters, in format:
    # Piece, (opt. disambiguation 1), (opt. disambiguation 2), destination column, destination row
    # Return it converted to an array.
    alg_to_array(alg_move, color)
  end

  def alg_check_castling(move, color)
    king_row = color == 'B' ? 0 : 7
    king_letter = color == 'B' ? 'k' : 'K'
    return [king_letter, [king_row, 4], [king_row, 6]] if %w[O-O 0-0].include?(move)

    return [king_letter, [king_row, 4], [king_row, 2]] if ['O-O-O', '0-0-0'].include?(move)

    false
  end

  def alg_attempted_move?(move)
    attempt = /^[a-hKQRBNP]{1}[a-h1-9x]{1,5}[+#?! ]*?$/
    not_end_with_x = /[^x]$/
    # Remove spaces anywhere in the string (allow player to input spaces)
    move_no_spaces = move.gsub(/\s+/, '')
    move_no_spaces.match?(attempt) && move_no_spaces.match?(not_end_with_x)
  end

  def alg_strip_chars(move)
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
    dest_row = @alg_map_row[alg_move.slice(-1)]
    dest_col = @alg_map_col[alg_move.slice(-2)]
    [dest_row, dest_col]
  end

  def alg_move_origin_square(alg_move)
    origin = alg_move[1..-3]
    case origin.length
    when 1
      /[1-8]/.match?(origin) ? orig_row = @alg_map_row[origin] : orig_col = @alg_map_col[origin]
    when 2
      orig_row = @alg_map_row[origin.slice(1)]
      orig_col = @alg_map_col[origin.slice(0)]
    end
    [orig_row, orig_col]
  end

  def alg_valid_move?(move)
    case move.length
    when 3
      move.match?(@validation_length3)
    when 4
      move.match?(@validation_length4)
    when 5
      move.match?(@validation_length5)
    else
      false
    end
  end

  def array_to_alg_move(move, capture = nil, legal_moves = nil, in_check: false)
    # Check for castling
    return array_check_castling(move) if array_check_castling(move)

    # Check that move is in the correct format
    return move unless move.length == 3 && move[0].is_a?(String) && move[1].is_a?(Array) && move[2].is_a?(Array)

    # Store the piece character capitalised.
    piece_char = move[0].upcase

    # Build the algebraic move in successive elements left to right.
    piece = piece_char == 'P' ? '' : piece_char
    disambiguation = array_disambiguate_move(move, legal_moves)
    pawn_col = array_pawn_capture(move, capture, piece_char)
    capturing = array_capturing(move, capture, piece_char)
    destination = array_destination(move)
    pawn_prom = array_pawn_prom(move, capture, piece_char)
    check = in_check ? '+' : ''

    # Return the formatted move with dots in place of missing elements: "Qa1xa3.+", ".d.xe4..", "....e8Q."
    "#{piece}#{disambiguation.join}#{pawn_col}#{capturing}#{destination.join}#{pawn_prom}#{check}"
  end

  def array_disambiguate_move(move, legal_moves)
    return ['', ''] unless legal_moves

    matches = legal_moves.select { |legal_move| legal_move[0] == move[0] && legal_move[2] == move[2] }
    [array_disambiguate_col(move, matches), array_disambiguate_row(move, matches)]
  end

  def array_disambiguate_col(move, matches)
    match_col = matches.select { |legal_move| legal_move[1][0] == move[1][0] }
    match_col.length > 1 ? @alg_map_col.key(move[1][1]) : ''
  end

  def array_disambiguate_row(move, matches)
    match_row = matches.select { |legal_move| legal_move[1][1] == move[1][1] }
    match_row.length > 1 ? @alg_map_row.key(move[1][0]) : ''
  end

  def array_check_castling(move)
    @array_map_castling[move] if @array_map_castling.include?(move)
  end

  def array_pawn_capture(move, capture, piece_char)
    return '' unless piece_char == 'P' && !capture.nil? && move[1][1] != move[2][1]

    @alg_map_col.key(move[1][1])
  end

  def array_capturing(move, capture, piece_char)
    capture.nil? || (piece_char == 'P' && move[1][1] == move[2][1]) ? '' : 'x'
  end

  def array_destination(move)
    [@alg_map_col.key(move[2][1]), @alg_map_row.key(move[2][0])]
  end

  def array_pawn_prom(move, capture, piece_char)
    piece_char == 'P' && (move[2][0].zero? || move[2][0] == 7) ? capture.to_s.upcase : ''
  end
end

# rubocop:enable Metrics/ClassLength
