# frozen_string_literal: true

require_relative '../lib/chess'

describe Chess do
  subject(:chess) { described_class.new(nil, PlayerHuman.new('W'), PlayerHuman.new('B')) }

  describe '#ask_player_move' do
    it 'accepts the move "e4"' do
      allow(subject.instance_variable_get(:@current_player)).to receive(:ask_move).and_return('e4')
      accepted_move = subject.ask_player_move([['P', [6, 4], [4, 4]]])
      expect(accepted_move).to eql(['P', [6, 4], [4, 4]])
    end
  end
end
