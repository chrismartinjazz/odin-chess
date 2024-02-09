# frozen_string_literal: true

require_relative 'chess'

Dir.mkdir 'saves' unless Dir.exist? 'saves'
Chess.new.game_loop
