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
      update_display(legal_moves)
      return result if legal_moves.empty?

      move = ask_player_move(legal_moves)
      save_game(game_state) if move == 'save'
      load_game if move == 'load'
      return 'Exiting...' if move == 'exit'

      make_move(move) unless %w[save load].include?(move)
    end
  end

  def make_move(move)
    @move_list << move
    return "#{@current_player.color == 'W' ? 'White' : 'Black'} resigns." if move == 'resigns'

    @game_board.move_piece(move)
    next_player
  end

  def result
    if @game_board.in_check?(@current_player.color)
      @move_list << '#'
      "#{@current_player.color == 'W' ? 'White' : 'Black'} is checkmated."
    else
      @move_list << 'stalemate'
      'Draw by stalemate.'
    end
  end

  def update_display(legal_moves)
    puts
    puts @current_player.color
    puts @game_board.display
    p legal_moves
    puts
    p @move_list
  end

  def ask_player_move(legal_moves)
    accepted_move = false
    until accepted_move
      move = @current_player.ask_move
      return move if %w[resigns exit save load].include?(move)

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
    p game_data
    @current_player = game_data[:current_player_color] == 'W' ? @player1 : @player2
    @move_list = game_data[:move_list]
    @game_board = GameBoard.new(game_data[:position])
  end
end
