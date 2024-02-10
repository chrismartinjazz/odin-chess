# Structure

## Chess (278)
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
    - Identifying if a given move is unique in the set of legal moves (could move to MoveConverter?). No 'change of state' involved
    - Handling the end of game / save / load options. No 'change of state'.
    - Displaying the game state. No 'change of state'.

## GameBoard (164)
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

## Player (47)
- Player knows
    - Their own color
- Player holds onto
    - MoveConverter(ComputerPlayer holds onto)
- Player includes
    - Nothing
- Player is reponsible for
    - Selecting and communicating moves

## MoveConverter (147)
- MoveConverter knows
    - Constants only - regex validations and hashes.

