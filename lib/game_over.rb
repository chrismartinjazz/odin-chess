# frozen_string_literal: true

require_relative 'file_manager'

# Handles the end of the game
module GameOver
  def game_over(condition)
    player_in_check = @game_board.in_check?(@current_player.color)
    if condition == 'no legal moves' && player_in_check
      message = handle_checkmate
    elsif condition == 'no legal moves' && !player_in_check
      message = handle_stalemate
    elsif condition == 'draw'
      message = handle_draw
    elsif condition == 'resign'
      message = handle_resign
    elsif condition == 'fifty move rule'
      message = handle_fifty_move_rule
    elsif condition == 'insufficient material'
      message = handle_insufficient_material
    end
    puts UpdateDisplay.update_display(@current_player, @move_list, @game_board)
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

  def handle_insufficient_material
    @move_list.push('(=)', '½–½')
    'Game drawn - insufficient material.'
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
                             position: %w[
                               rnbqkbnr
                               pppppppp
                               ........
                               ........
                               ........
                               ........
                               PPPPPPPP
                               RNBQKBNR
                             ] })
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
    game_data ? new_game(game_data) : new_game
  end
end
