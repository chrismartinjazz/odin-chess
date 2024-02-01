# frozen_string_literal: true

class Player
  def ask_move
    print '>> '
    gets.chomp.strip.downcase
  end
end
