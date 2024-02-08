# frozen_string_literal: true

require_relative 'chess'

game = Chess.new
result = game.game_loop
puts '======================='
puts result
p game.move_list
