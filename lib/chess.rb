# frozen_string_literal: true

require_relative 'game_board'
require_relative 'player'
require_relative 'move_converter'
require_relative 'file_manager'

# The main game loop
class Chess
  attr_reader :move_list

  def initialize(position = %w[
    rnbqkbnr
    pppppppp
    ........
    ........
    ........
    ........
    PPPPPPPP
    RNBQKBNR
  ])
    @game_board = GameBoard.new(position)
    @player1 = Player.new('W')
    @player2 = Player.new('B')
    @move_converter = MoveConverter.new
    @current_player = @player1
    @move_list = []
    @file_manager = FileManager.new
  end

  def game_loop
    loop do
      legal_moves = @game_board.legal_moves(@current_player.color)
      puts update_display
      move = ask_player_move(legal_moves) unless legal_moves.empty?
      save_game(game_state) if move == 'save'
      load_game if move == 'load'
      return 'Exiting...' if move == 'exit'

      if legal_moves.empty? || %w[draw resign].include?(move)
        game_over(move, legal_moves)
      else
        make_move(move, legal_moves) unless %w[save load].include?(move)
      end
    end
  end

  def make_move(move, legal_moves)
    # TODO: Fix resigns logic so it will run. It all needs to be moved to end of move cycle.
    return "#{@current_player.color == 'W' ? 'White' : 'Black'} resigns." if move == 'resigns'

    capture = @game_board.move_piece(move)
    @move_list << @move_converter.array_to_alg_move(move, capture, legal_moves,
                                                    in_check: @game_board.in_check?(@current_player.color))
    next_player
  end

  def game_over(move, legal_moves)
    player_in_check = @game_board.in_check?(@current_player.color)
    if legal_moves.empty? && player_in_check
      @move_list.push('#', @current_player.color == 'W' ? '0-1' : '1-0')
    elsif legal_moves.empty? && !player_in_check
      @move_list.push('stalemate', '½–½')
    elsif move == 'draw'
      @move_list.push('(=)', '½–½')
    elsif move == 'resign'
      @move_list.push('resigns', @current_player.color == 'W' ? '0-1' : '1-0')
    end
  end

  def update_display
    clear_screen
    display = display_title
    display += display_current_player
    display += @game_board.display
    display + "\n"
  end

  def clear_screen(testing: false)
    return if testing == true

    Gem.win_platform? ? (system 'cls') : (system 'clear')
  end

  def display_title
    <<~HEREDOC
        ___ _    ___      _
       / __| |  |_ _|  __| |_  ___ ______
      | (__| |__ | |  / _| ' \\/ -_|_-<_-<
       \\___|____|___| \\__|_||_\\___/__/__/

        use algebraic notation to move

         options (type in lower case)
      save : load : resign : draw : exit

    HEREDOC
  end

  def display_current_player
    display = ''
    display += @current_player.color == 'W' ? ">> White <<\n" : "   White\n"
    display += @current_player.color == 'B' ? ">> Black <<\n" : "   Black\n"
    display + "\n"
  end

  def ask_player_move(legal_moves)
    accepted_move = false
    until accepted_move
      move = @current_player.ask_move
      return move if %w[resign draw exit save load].include?(move)

      valid_move = @move_converter.convert(move, @current_player.color)
      accepted_move = in_legal_moves(valid_move, legal_moves) if valid_move
    end
    accepted_move
  end

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
    # Disambiguation - original row&col, row, column
    row_col = matches.select { |match| match[1] == move[1] }
    return row_col[0] if row_col.size == 1

    row = matches.select { |match| match[1][0] == move[1][0] }
    return row[0] if row.size == 1

    col = matches.select { |match| match[1][1] == move[1][1] }
    return col[0] if col.size == 1

    false
  end

  def next_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

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
    set_game_state(game_data)
  end

  def set_game_state(game_data)
    @current_player = game_data[:current_player_color] == 'W' ? @player1 : @player2
    @move_list = game_data[:move_list]
    @game_board = GameBoard.new(game_data[:position])
  end
end
