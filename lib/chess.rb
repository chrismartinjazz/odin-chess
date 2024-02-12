# frozen_string_literal: true

require_relative 'game_board'
require_relative 'player'
require_relative 'move_converter'
require_relative 'file_manager'
require_relative 'update_display'
# rubocop:disable Metrics/ClassLength

# The main game loop
class Chess
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

  # Handle game end/save/load/game over
  def game_over(move, legal_moves_list)
    player_in_check = @game_board.in_check?(@current_player.color)
    if legal_moves_list.empty? && player_in_check
      message = handle_checkmate
    elsif legal_moves_list.empty? && !player_in_check
      message = handle_stalemate
    elsif move == 'draw'
      message = handle_draw
    elsif move == 'resign'
      message = handle_resign
    end
    puts update_display(@current_player, @move_list, @game_board)
    puts message
    new_save_load_exit(ask_game_over_action)
  end

  def handle_checkmate
    @move_list.push('#', @current_player.color == 'W' ? '0-1' : '1-0')
    "#{@current_player.color == 'W' ? 'Black' : 'White'} wins by checkmate.\n\n"
  end

  def handle_stalemate
    @move_list.push('stalemate', '½–½')
    "#{@current_player.color == 'W' ? 'White' : 'Black'} is stalemated.\n\n"
  end

  def handle_draw
    @move_list.push('(=)', '½–½')
    'Game drawn.'
  end

  def handle_resign
    @move_list.push('resigns', @current_player.color == 'W' ? '0-1' : '1-0')
    "#{@current_player.color == 'W' ? 'White' : 'Black'} resigns.\n\n"
  end

  def ask_game_over_action
    action = nil
    puts 'new : load : exit ?'
    until action
      print '>> '
      input = gets.chomp.strip.downcase
      action = input if %w[new load exit].include?(input)
    end
    action
  end

  # Handle game save/load/game over
  def new_save_load_exit(action)
    case action
    when 'new'
      new_game
    when 'save'
      save_game(game_state)
    when 'load'
      load_game
    when 'exit'
      system(exit)
    end
  end

  def new_game(game_data = { current_player_color: 'W',
                             move_list: [],
                             position: @initial_position })
    @current_player = game_data[:current_player_color] == 'W' ? @player1 : @player2
    @move_list = game_data[:move_list]
    @game_board = GameBoard.new(game_data[:position])
  end

  def save_game(game_state)
    puts @file_manager.save_file(game_state) ? "\nSave successful" : "\nFile not saved"
    puts 'Press Enter to continue'
    gets
    nil
  end

  def game_state
    {
      current_player_color: @current_player.color,
      move_list: @move_list,
      position: @game_board.write_position
    }
  end

  def load_game
    game_data = @file_manager.load_file
    new_game(game_data)
  end
end

# rubocop:enable Metrics/ClassLength
