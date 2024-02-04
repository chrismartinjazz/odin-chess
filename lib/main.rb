# frozen_string_literal: true

require_relative 'chess'

starting_board = %w[
  rnbqkbnr
  pppppppp
  ........
  ........
  ........
  ........
  PPPPPPPP
  RNBQKBNR
]
Chess.new(starting_board).game_loop
