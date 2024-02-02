# frozen_string_literal: true

require_relative 'game_board'
require_relative 'player'

class Chess
  def initialize(position = nil)
    @game_board = GameBoard.new
    @player1 = Player.new
  end

  def convert(move)
    return check_castling(move) if check_castling(move)

    stripped_move = strip_chars(move)
  end

  def check_castling(move)
    return [['K'], [nil, nil], [7, 6]] if move == 'O-O'

    return [['K'], [nil, nil], [7, 2]] if move == 'O-O-O'

    false
  end

  def strip_chars(move)
    stripped_move = ''
    (0..move.length - 1).each do |index|
      stripped_move += /[a-h1-8KQRBNP]/.match(test.slice(i)) ? test.slice(i) : ''
    end
    stripped_move
  end
end
