# frozen_string_literal: true

# TODO: This should definitely be a module instead - all behaviour, no state.
class MoveConverter
  def initialize
    @validation_length3 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}$/
    @validation_length4 = /^[KQRNBP]{1}[a-h1-8]{1}[a-h]{1}[1-8]{1}$/
    @validation_length5 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}[a-h]{1}[1-8]{1}$/
    # TODO: CHange these to hashes as well.
    @alg_map_row = [[nil, '8', '7', '6', '5', '4', '3', '2', '1'], [nil, 0, 1, 2, 3, 4, 5, 6, 7]]
    @alg_map_col = [[nil, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'], [nil, 0, 1, 2, 3, 4, 5, 6, 7]]
    @array_map_castling = {
      ['K', [7, 4], [7, 6]] => '0-0',
      ['K', [7, 4], [7, 2]] => '0-0-0',
      ['k', [0, 4], [0, 6]] => '0-0',
      ['k', [0, 4], [0, 2]] => '0-0-0'
    }
  end

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
    dest_row = @alg_map_row[1][@alg_map_row[0].index(alg_move.slice(-1))]
    dest_col = @alg_map_col[1][@alg_map_col[0].index(alg_move.slice(-2))]

    origin = alg_move[1..-3]
    case origin.length
    when 1
      if /[1-8]/.match?(origin)
        orig_row = @alg_map_row[1][@alg_map_row[0].index(origin.slice(0))]
      else
        orig_col = @alg_map_col[1][@alg_map_col[0].index(origin.slice(0))]
      end
    when 2
      orig_row = @alg_map_row[1][@alg_map_row[0].index(origin.slice(1))]
      orig_col = @alg_map_col[1][@alg_map_col[0].index(origin.slice(0))]
    end

    move_array = [alg_move.slice(0), [orig_row, orig_col], [dest_row, dest_col]]
    move_array[0].downcase! if color == 'B'
    move_array
  end

  def valid_move?(move)
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
    return array_check_castling(move) if array_check_castling(move)

    return move if %w[# stalemate resigns].include?(move)

    piece_char = move[0].upcase

    piece = piece_char == 'P' ? '' : move[0].upcase
    disambiguation = array_disambiguate_move(move, legal_moves)
    pawn_col = array_pawn_capture(move, capture, piece_char)
    capturing = array_capturing(move, capture, piece_char)
    dest_col = @alg_map_col[0][@alg_map_col[1].index(move[2][1])]
    dest_row = @alg_map_row[0][@alg_map_row[1].index(move[2][0])]
    pawn_prom = array_pawn_prom(move, capture, piece_char)
    check = in_check ? '+' : ''

    "#{piece}#{disambiguation[0]}#{disambiguation[1]}#{pawn_col}#{capturing}#{dest_col}#{dest_row}#{pawn_prom}#{check}"
  end

  def array_disambiguate_move(move, legal_moves)
    disambiguation = ['', '']
    return disambiguation unless legal_moves

    matches = legal_moves.select { |legal_move| legal_move[0] == move[0] && legal_move[2] == move[2] }
    match_col = matches.select { |legal_move| legal_move[1][0] == move[1][0] }
    match_row = matches.select { |legal_move| legal_move[1][1] == move[1][1] }
    disambiguation[0] = @alg_map_col[0][@alg_map_col[1].index(move[1][1])] if match_col.length > 1
    disambiguation[1] = @alg_map_row[0][@alg_map_row[1].index(move[1][0])] if match_row.length > 1
    disambiguation
  end

  def array_check_castling(move)
    @array_map_castling[move] if @array_map_castling.include?(move)
  end

  def array_pawn_capture(move, capture, piece_char)
    return '' unless piece_char == 'P' && !capture.nil? && move[1][1] != move[2][1]

    @alg_map_col[0][@alg_map_col[1].index(move[1][1])]
  end

  def array_capturing(move, capture, piece_char)
    capture.nil? || (piece_char == 'P' && move[1][1] == move[2][1]) ? '' : 'x'
  end

  def array_pawn_prom(move, capture, piece_char)
    piece_char == 'P' && (move[2][0] == 0 || move[2][0] == 7) ? capture.to_s.upcase : ''
  end
end
