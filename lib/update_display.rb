# frozen_string_literal: true

# Updates all elements of the display
module UpdateDisplay
  extend self

  def update_display(current_player, move_list, game_board)
    clear_screen
    "#{game_board.fifty_move_counter}\n#{display_title}#{display_current_player(current_player)}#{game_board.display}#{display_move_list(move_list)}\n"
  end

  private

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
         save : load : new : resign : draw : exit

    HEREDOC
  end

  def display_current_player(current_player)
    <<~HEREDOC
      #{current_player.color == 'W' ? '>> White <<' : '   White'}
      #{current_player.color == 'B' ? '>> Black <<' : '   Black'}

    HEREDOC
  end

  def display_move_list(move_list)
    game_result = move_list.pop if %w[1-0 0-1 ½–½].include?(move_list[-1])
    win_condition = move_list.pop if %w[# stalemate (=) resigns].include?(move_list[-1])
    collated_move_list = collate_move_list(move_list)
    "\n#{collated_move_list}#{win_condition} #{game_result}\n"
  end

  def collate_move_list(move_list)
    display = ''
    move_list.compact!
    move_list.push(nil) if move_list.length.odd?
    return display if move_list.empty?

    (0..move_list.length - 2).step(2) do |pair_index|
      display += collate_move_pair(pair_index, move_list)
    end
    display
  end

  def collate_move_pair(pair_index, move_list)
    "#{(pair_index + 2) / 2}. #{move_list[pair_index]} #{move_list[pair_index + 1]} "
  end
end
