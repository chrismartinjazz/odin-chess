# frozen_string_literal: true

require_relative 'game_board'
require_relative 'player'
require_relative 'move_converter'
require_relative 'file_manager'
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength

# The main game loop
class Chess
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

  # Initialization
  def ask_player_type(color)
    puts "#{color} player is (h)uman or (c)omputer:"
    valid_input = nil
    until valid_input
      print '>>'
      input = gets.chomp.strip.downcase.slice(0)
      valid_input = input if %w[h c].include?(input)
    end
    if valid_input == 'c'
      PlayerComputer.new(color.slice(0))
    else
      PlayerHuman.new(color.slice(0))
    end
  end

  # Game play
  def game_loop
    loop do
      legal_moves = @game_board.legal_moves(@current_player.color)
      puts update_display
      move = ask_player_move(legal_moves) unless legal_moves.empty?
      new_save_load_exit(move) if %w[new save load exit].include?(move)
      if legal_moves.empty? || %w[draw resign].include?(move)
        game_over(move, legal_moves)
      else
        make_move(move, legal_moves) unless %w[save load new].include?(move)
      end
    end
  end

  # Game play
  def ask_player_move(legal_moves)
    accepted_move = false
    until accepted_move
      move = @current_player.ask_move(legal_moves)
      return move if %w[save load new resign draw exit].include?(move)

      valid_move = @move_converter.convert(move, @current_player.color)
      accepted_move = in_legal_moves(valid_move, legal_moves) if valid_move
    end
    sleep(0.5) if @current_player.is_a?(PlayerComputer)
    accepted_move
  end

  # Game play
  def make_move(move, legal_moves)
    promotion_piece = @current_player.ask_promotion_piece if pawn_promoting?(move)
    capture = @game_board.move_piece(move, promotion_piece)
    @move_list << @move_converter.array_to_alg_move(move, capture, legal_moves,
                                                    in_check: @game_board.in_check?(@current_player.color))
    next_player
  end

  def pawn_promoting?(move)
    move[0].upcase == 'P' && (move[2][0].zero? || move[2][0] == 7)
  end

  # Could these methods and logic go into MoveConverter? Yes but then MoveConverter is coupled through to legal_moves.
  # So this is the 'part' of the move analysis that links together the legal_moves and the move_converter.
  def in_legal_moves(move, legal_moves)
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
    matching_moves = matches.select { |match| match[1] == move[1] }
    row_col[0] if matching_moves.size == 1
  end

  def disambiguate_matching_row(move, matches)
    matching_moves = matches.select { |match| match[1][0] == move[1][0] }
    row_col[0] if matching_moves.size == 1
  end

  def disambiguate_matching_col(move, matches)
    matching_moves = matches.select { |match| match[0][1] == move[0][1] }
    row_col[0] if matching_moves.size == 1
  end

  # Game play
  def next_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  # Handle game save/load/game over
  def game_over(move, legal_moves)
    player_in_check = @game_board.in_check?(@current_player.color)
    if legal_moves.empty? && player_in_check
      @move_list.push('#', @current_player.color == 'W' ? '0-1' : '1-0')
      puts "#{@current_player.color == 'W' ? 'Black' : 'White'} wins by checkmate.\n"
    elsif legal_moves.empty? && !player_in_check
      @move_list.push('stalemate', '½–½')
      puts "#{@current_player.color == 'W' ? 'White' : 'Black'} is stalemated.\n"
    elsif move == 'draw'
      @move_list.push('(=)', '½–½')
      puts 'Game drawn.'
    elsif move == 'resign'
      @move_list.push('resigns', @current_player.color == 'W' ? '0-1' : '1-0')
      puts "#{@current_player.color == 'W' ? 'White' : 'Black'} resigns.\n"
    end
    puts 'new : load : exit ?'
    action = nil
    until action
      print '>> '
      input = gets.chomp.strip.downcase
      action = input if %w[new load exit].include?(input)
    end
    new_save_load_exit(action)
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
      puts display_move_list
      system(exit)
    end
  end

  # ===========================MOVE TO DISPLAY MODULE?
  # Display the board etc.
  def display_move_list
    display = "\n"
    game_result = move_list.pop if %w[1-0 0-1 ½–½].include?(move_list[-1])
    win_condition = move_list.pop if %w[# stalemate (=) resigns].include?(move_list[-1])
    move_list.compact!
    move_list.push(nil) if move_list.length.odd?
    unless move_list.empty?
      (0..move_list.length - 2).step(2) do |index|
        display += "#{(index + 2) / 2}. #{move_list[index]} #{move_list[index + 1]} "
      end
    end
    display + "#{win_condition} #{game_result}\n"
  end

  # Display
  def update_display
    clear_screen
    display = display_title
    display += display_current_player
    display += @game_board.display
    display += display_move_list
    display + "\n"
  end

  # Display
  def clear_screen(testing: false)
    return if testing == true

    Gem.win_platform? ? (system 'cls') : (system 'clear')
  end

  # Display
  def display_title
    <<~HEREDOC
        ___ _    ___      _
       / __| |  |_ _|  __| |_  ___ ______
      | (__| |__ | |  / _| ' \\/ -_|_-<_-<
       \\___|____|___| \\__|_||_\\___/__/__/

         use algebraic notation to move

         options (type in lower case)
         save : load : new : resign : draw : exit

    HEREDOC
  end

  # Display
  def display_current_player
    display = ''
    display += @current_player.color == 'W' ? ">> White <<\n" : "   White\n"
    display += @current_player.color == 'B' ? ">> Black <<\n" : "   Black\n"
    display + "\n"
  end

  # ==================================================MOVE TO SAVE GAME MODULE
  # Saving and loading of the game - needs to be elsewhere.
  def game_state
    {
      current_player_color: @current_player.color,
      move_list: @move_list,
      position: @game_board.write_position
    }
  end

  def save_game(game_state)
    puts @file_manager.save_file(game_state) ? "\nSave successful" : "\nFile not saved"
    puts 'Press Enter to continue'
    gets
    nil
  end

  def load_game
    game_data = @file_manager.load_file
    new_game(game_data)
  end

  def new_game(game_data = { current_player_color: 'W',
                             move_list: [],
                             position: @initial_position })
    @current_player = game_data[:current_player_color] == 'W' ? @player1 : @player2
    @move_list = game_data[:move_list]
    @game_board = GameBoard.new(game_data[:position])
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/MethodLength
