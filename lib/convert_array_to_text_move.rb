# frozen_string_literal: true

# Takes an array representing a chess move [<piece>, <origin>, <destination>] and converts
# it into a standard chess algebraic move, including disambiguation of row and col if required.
module ConvertArrayToTextMove
  MAP_ROW = { nil => nil, '8' => 0, '7' => 1, '6' => 2, '5' => 3, '4' => 4, '3' => 5, '2' => 6, '1' => 7 }.freeze
  MAP_COL = { nil => nil, 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, 'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7 }.freeze
  MAP_CASTLING = {
    ['K', [7, 4], [7, 6]] => '0-0',
    ['K', [7, 4], [7, 2]] => '0-0-0',
    ['k', [0, 4], [0, 6]] => '0-0',
    ['k', [0, 4], [0, 2]] => '0-0-0'
  }.freeze

  def convert_array_to_text_move(move, capture = nil, legal_moves = nil, in_check: false)
    return castling(move) if castling(move)

    return move unless expected_format?(move)

    piece_char = move[0].upcase

    piece = piece_char == 'P' ? '' : piece_char
    disambiguation = disambiguate_move(move, legal_moves)
    pawn_col = pawn_capture(move, capture, piece_char)
    capturing = capturing(move, capture, piece_char)
    destination = destination(move)
    pawn_prom = pawn_prom(move, capture, piece_char)
    check = in_check ? '+' : ''

    # Return the formatted move with dots in place of missing elements: "Qa1xa3.+", ".d.xe4..", "....e8Q."
    "#{piece}#{disambiguation.join}#{pawn_col}#{capturing}#{destination.join}#{pawn_prom}#{check}"
  end

  def castling(move)
    MAP_CASTLING[move] if MAP_CASTLING.include?(move)
  end

  def expected_format?(move)
    move.length == 3 && move[0].is_a?(String) && move[1].is_a?(Array) && move[2].is_a?(Array)
  end

  def disambiguate_move(move, legal_moves)
    return ['', ''] unless legal_moves

    matches = legal_moves.select { |legal_move| legal_move[0] == move[0] && legal_move[2] == move[2] }
    [disambiguate_col(move, matches), disambiguate_row(move, matches)]
  end

  def disambiguate_col(move, matches)
    match_col = matches.select { |legal_move| legal_move[1][0] == move[1][0] }
    match_col.length > 1 ? MAP_COL.key(move[1][1]) : ''
  end

  def disambiguate_row(move, matches)
    match_row = matches.select { |legal_move| legal_move[1][1] == move[1][1] }
    match_row.length > 1 ? MAP_ROW.key(move[1][0]) : ''
  end

  def pawn_capture(move, capture, piece_char)
    return '' unless piece_char == 'P' && !capture.nil? && move[1][1] != move[2][1]

    MAP_COL.key(move[1][1])
  end

  def capturing(move, capture, piece_char)
    capture.nil? || (piece_char == 'P' && move[1][1] == move[2][1]) ? '' : 'x'
  end

  def destination(move)
    [MAP_COL.key(move[2][1]), MAP_ROW.key(move[2][0])]
  end

  def pawn_prom(move, capture, piece_char)
    piece_char == 'P' && (move[2][0].zero? || move[2][0] == 7) ? capture.to_s.upcase : ''
  end
end
