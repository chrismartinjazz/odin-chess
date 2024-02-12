# frozen_string_literal: true

require_relative 'game_board'
require_relative 'player'
require_relative 'move_converter'
require_relative 'file_manager'
require_relative 'game_over'
require_relative 'update_display'

# The main game loop
class Chess
  include GameOver
  include UpdateDisplay

  attr_reader :move_list

  def initialize(position = nil, player1 = nil, player2 = nil)
    @initial_position = position || %w[
      rnbqkbnr
      pppppppp
      ........
      ........
      ........
      ........
      PPPPPPPP
      RNBQKBNR
    ]
    @player1 = player1 || ask_player_type('White')
    @player2 = player2 || ask_player_type('Black')
    @game_board = GameBoard.new(@initial_position)
    @move_converter = MoveConverter.new
    @current_player = @player1
    @move_list = []
    @file_manager = FileManager.new
  end

  def ask_player_type(color)
    puts "\n#{color} player is (h)uman or (c)omputer:"
    valid_input = nil
    until valid_input
      print '>> '
      input = gets.chomp.strip.downcase.slice(0)
      valid_input = input if %w[h c human computer].include?(input)
    end
    input.slice(0) == 'c' ? PlayerComputer.new(color.slice(0)) : PlayerHuman.new(color.slice(0))
  end

  def game_loop
    loop do
      puts update_display(@current_player, @move_list, @game_board)
      legal_moves_list = @game_board.find_legal_moves(@current_player.color)
      move = ask_player_move(legal_moves_list) unless legal_moves_list.empty?
      new_save_load_exit(move) if %w[new save load exit].include?(move)
      if legal_moves_list.empty? || %w[draw resign].include?(move)
        puts update_display(@current_player, @move_list, @game_board)
        game_over(move, legal_moves_list)
        next
      end
      make_move(move, legal_moves_list) unless %w[new save load].include?(move)
    end
  end

  def ask_player_move(legal_moves_list)
    accepted_move = false
    until accepted_move
      move = @current_player.ask_move(legal_moves_list)
      return move if %w[save load new resign draw exit].include?(move)

      valid_move = @move_converter.alg_move_to_array(move, @current_player.color)
      accepted_move = in_legal_moves(valid_move, legal_moves_list) if valid_move
    end
    sleep(0.5) if @current_player.is_a?(PlayerComputer)
    accepted_move
  end

  def make_move(move, legal_moves_list)
    promotion_piece = @current_player.ask_promotion_piece if pawn_promoting?(move)
    capture = @game_board.move_piece(move, promotion_piece)
    @move_list << @move_converter.array_to_alg_move(move, capture, legal_moves_list,
                                                    in_check: @game_board.in_check?(@current_player.color))
    next_player
  end

  def pawn_promoting?(move)
    move[0].upcase == 'P' && (move[2][0].zero? || move[2][0] == 7)
  end

  def next_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  # Could these methods and logic go into MoveConverter? Yes but then MoveConverter is coupled through to legal_moves.
  # MoveConverter just knows how to convert algebraic notation to a move and vice versa.
  # I guess it could be given legal_moves as an optional parameter? Possible.
  # Currently this is the 'part' of the move analysis that links together the legal_moves and the move_converter.
  def in_legal_moves(move, legal_moves_list)
    matches = legal_moves_list.select { |legal_move| legal_move[0] == move[0] && legal_move[2] == move[2] }
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
