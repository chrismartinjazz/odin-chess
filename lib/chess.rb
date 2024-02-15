# frozen_string_literal: true

require_relative 'convert'
require_relative 'game_board'
require_relative 'game_over'
require_relative 'player'
require_relative 'update_display'

# Chess game using algebraic move input
class Chess
  include GameOver

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
    @current_player = @player1
    @move_list = []
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
      puts UpdateDisplay.update_display(@current_player, @move_list, @game_board)
      legal_moves_list = @game_board.find_legal_moves(@current_player.color)
      move = ask_player_move(legal_moves_list) unless legal_moves_list.empty?
      new_save_load_exit(move) if %w[new save load exit].include?(move)

      if legal_moves_list.empty? || %w[draw resign].include?(move) || @game_board.fifty_move_counter >= 50
        game_over('no legal moves') if legal_moves_list.empty?
        game_over(move) if %w[draw resign].include?(move)
        game_over('fifty move rule') if @game_board.fifty_move_counter >= 50
        next
      end
      capture = make_move(move, legal_moves_list) unless %w[new save load].include?(move)
      check_for_insufficient_material if capture
    end
  end

  def ask_player_move(legal_moves_list)
    accepted_move = false
    until accepted_move
      move = @current_player.ask_move(legal_moves_list)
      return move if %w[save load new resign draw exit].include?(move)

      accepted_move = Convert::TextToArray.text_to_array(move, @current_player.color, legal_moves_list)
    end
    sleep(0.05) if @current_player.is_a?(PlayerComputer)
    accepted_move
  end

  def make_move(move, legal_moves_list)
    promotion_piece = @current_player.ask_promotion_piece if pawn_promoting?(move)
    capture = @game_board.move_piece(move, promotion_piece)
    @move_list << Convert::ArrayToText.array_to_text(move, capture, legal_moves_list,
                                                     in_check: @game_board.in_check?(@current_player.color))
    next_player
    capture
  end

  def check_for_insufficient_material
    return unless %w[K KN BK KNN].include?(@game_board.material['W'])

    return unless %w[k kn bk knn].include?(@game_board.material['B'])

    game_over('insufficient material')
  end

  def pawn_promoting?(move)
    move[0].upcase == 'P' && (move[2][0].zero? || move[2][0] == 7)
  end

  def next_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end
end
