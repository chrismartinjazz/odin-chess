# frozen_string_literal: true

require_relative 'file_manager'

# Handles the end of the game
module GameOver
  def game_over(move, legal_moves_list, fifty_move_counter)
    player_in_check = @game_board.in_check?(@current_player.color)
    if legal_moves_list.empty? && player_in_check
      message = handle_checkmate
    elsif legal_moves_list.empty? && !player_in_check
      message = handle_stalemate
    elsif move == 'draw'
      message = handle_draw
    elsif move == 'resign'
      message = handle_resign
    elsif fifty_move_counter > 50
      message = handle_fifty_move_rule
    end
    puts message
    new_save_load_exit(ask_game_over_action)
  end

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

  def handle_fifty_move_rule
    @move_list.push('(=)', '½–½')
    'Game drawn - fifty moves without a pawn move or capture.'
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

  def new_game(game_data = { current_player_color: 'W',
                             move_list: [],
                             position: @initial_position })
    @current_player = game_data[:current_player_color] == 'W' ? @player1 : @player2
    @move_list = game_data[:move_list]
    @game_board = GameBoard.new(game_data[:position])
  end

  def save_game(game_state)
    puts FileManager.save_file(game_state) ? "\nSave successful" : "\nFile not saved"
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
    game_data = FileManager.load_file
    new_game(game_data)
  end
end
