Structure

- Chess (278)
- Chess knows
    - The current player
    - The sequence of moves in the game
- Chess holds onto
    - GameBoard @game_board
    - Player @player1 @player2
    - MoveConverter @move_converter
    - FileManager @file_manager
- Chess includes
    - Nothing
- Chess is responsible for
    - Running the game loop


- GameBoard (164)
- GameBoard knows
    - The state of the board
    - If castling is possible
    - If en_passant is possible
    - Where the king is (only during test_for_check... so prob move this)
- GameBoard holds onto
    - PositionReadWrite @position_read_write
    - BoardDisplayer @board_displayer
- GameBoard includes
    - LegalMoves
- GameBoard is responsible for
    - Moving pieces
    - Testing for check

- Player (47)
- Player knows
    - Their own color
- Player holds onto
    - MoveConverter(ComputerPlayer holds onto)
- Player includes
    - Nothing
- Player is reponsible for
    - Selecting moves

- MoveConverter
- MoveConverter knows
