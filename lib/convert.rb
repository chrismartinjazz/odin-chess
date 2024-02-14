# frozen_string_literal: true

# Converts a Chess move
module Convert
  MAP_ROW = { nil => nil, '8' => 0, '7' => 1, '6' => 2, '5' => 3, '4' => 4, '3' => 5, '2' => 6, '1' => 7 }.freeze
  MAP_COL = { nil => nil, 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3, 'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7 }.freeze

  extend self

  # Converts algebraic move to an array [<piece>, <origin>, <destination>]
  module TextToArray
    VALIDATION_ATTEMPT = /^[a-hKQRBNP]{1}[a-h1-9x]{1,5}[+#?! ]*?$/
    VALIDATION_NOT_END_WITH_X = /[^x]$/
    VALIDATION_ALGEBRAIC = /[a-h1-8KQRBNP]/

    VALIDATION_LENGTH3 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}$/
    VALIDATION_LENGTH4 = /^[KQRNBP]{1}[a-h1-8]{1}[a-h]{1}[1-8]{1}$/
    VALIDATION_LENGTH5 = /^[KQRNBP]{1}[a-h]{1}[1-8]{1}[a-h]{1}[1-8]{1}$/

    extend self

    def text_to_array(move, color, legal_moves = nil)
      return castling(move, color) if %w[O-O 0-0 O-O-O 0-0-0].include?(move)

      return nil unless attempted_move?(move)

      stripped_move = strip_non_algebraic_chars(move)
      stripped_move.prepend('P') unless stripped_move.slice(0).upcase == stripped_move.slice(0)
      return nil unless valid_move?(stripped_move)

      # Move is now 3-5 characters, in format:
      # Piece, (opt. disambiguation 1), (opt. disambiguation 2), destination column, destination row
      move_array = convert_to_array(stripped_move, color)
      return match_legal_moves(move_array, legal_moves) if legal_moves

      move_array
    end

    private

    def castling(move, color)
      king_row = color == 'W' ? 7 : 0
      king_letter = color == 'W' ? 'K' : 'k'
      return [king_letter, [king_row, 4], [king_row, 6]] if %w[O-O 0-0].include?(move)

      return [king_letter, [king_row, 4], [king_row, 2]] if ['O-O-O', '0-0-0'].include?(move)

      false
    end

    def attempted_move?(move)
      move_no_spaces = move.gsub(/\s+/, '')
      move_no_spaces.match?(VALIDATION_ATTEMPT) && move_no_spaces.match?(VALIDATION_NOT_END_WITH_X)
    end

    def strip_non_algebraic_chars(move)
      alg_move = ''
      move.each_char { |char| alg_move += char if char.match?(VALIDATION_ALGEBRAIC) }
      alg_move
    end

    def valid_move?(move)
      case move.length
      when 3
        move.match?(VALIDATION_LENGTH3)
      when 4
        move.match?(VALIDATION_LENGTH4)
      when 5
        move.match?(VALIDATION_LENGTH5)
      else
        false
      end
    end

    def convert_to_array(stripped_move, color)
      piece = color == 'W' ? stripped_move.slice(0) : stripped_move.slice(0).downcase
      origin_square = convert_origin_square(stripped_move)
      destination_square = convert_destination_square(stripped_move)
      [piece, origin_square, destination_square]
    end

    def convert_origin_square(stripped_move)
      origin = stripped_move[1..-3]
      case origin.length
      when 1
        /[1-8]/.match?(origin) ? orig_row = MAP_ROW[origin] : orig_col = MAP_COL[origin]
      when 2
        orig_row = MAP_ROW[origin.slice(1)]
        orig_col = MAP_COL[origin.slice(0)]
      end
      [orig_row, orig_col]
    end

    def convert_destination_square(stripped_move)
      dest_row = MAP_ROW[stripped_move.slice(-1)]
      dest_col = MAP_COL[stripped_move.slice(-2)]
      [dest_row, dest_col]
    end

    def match_legal_moves(move, legal_moves)
      matches = legal_moves.select { |legal_move| legal_move[0] == move[0] && legal_move[2] == move[2] }
      case matches.length
      when 0
        false
      when 1
        matches[0]
      else
        disambiguate_move(move, matches)
      end
    end

    def disambiguate_move(move, matches)
      disambiguate_matching_square(move, matches) ||
        disambiguate_matching_row(move, matches) ||
        disambiguate_matching_col(move, matches) ||
        false
    end

    def disambiguate_matching_square(move, matches)
      matching_square = matches.select { |match| match[1] == move[1] }
      matching_square[0] if matching_square.size == 1
    end

    def disambiguate_matching_row(move, matches)
      matching_row = matches.select { |match| match[1][0] == move[1][0] }
      matching_row[0] if matching_row.size == 1
    end

    def disambiguate_matching_col(move, matches)
      matching_col = matches.select { |match| match[1][1] == move[1][1] }
      matching_col[0] if matching_col.size == 1
    end
  end

  # Converts an array [<piece>, <origin>, <destination>] to an algebraic chess move
  module ArrayToText
    MAP_CASTLING = {
      ['K', [7, 4], [7, 6]] => '0-0',
      ['K', [7, 4], [7, 2]] => '0-0-0',
      ['k', [0, 4], [0, 6]] => '0-0',
      ['k', [0, 4], [0, 2]] => '0-0-0'
    }.freeze

    extend self

    def array_to_text(move, capture = nil, legal_moves = nil, in_check: false)
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

    private

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
end
