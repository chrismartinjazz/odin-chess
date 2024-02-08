# frozen_string_literal: true

require_relative 'chess'

Dir.mkdir 'saves' unless Dir.exist? 'saves'
game = Chess.new
result = game.game_loop
puts '======================='
puts result
p game.move_list
