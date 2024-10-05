# odin-chess

Command line chess implemented as part of The Odin Project.

# Summary

This implementation of chess is for two players (human or computer) and is played in the terminal. The computer player simply chooses a random legal move in the position.

 Run `ruby lib/main.rb` from the root directory to play. After selecting human or computer players, the terminal is cleared and the game board displayed.

The key feature is a focus on algebraic notation. Moves are input using standard algebraic notation (e.g. e4 e5 Nf3 Nf6) including disambiguation of row and column (Rad4). The parser will accept symbols commonly found in algebraic notation such as +, #, !? (e.g. e4 e5 Bc4 Bc5 Qh5 Nf6?? Qf5#). If more than one piece of the same type can move to a given square and no disambiguation is provided, the move is rejected (e.g. white knights on a1 and c1, move Nb3 - rejected). After each move the list of moves in the game is updated below the board, again in algebraic notation. At the end of the game the move list shows the result in standard notation along with the complete set of moves. This allows a full game to be 'typed in' to the interface, when choosing human players.

The game can also be saved and loaded using an in-game interface.

Standard chess features implemented are:

- Check
- Castling (e.g. 0-0 or O-O for king-side, 0-0-0 or O-O-O for queen side)
- Pawn promotion (e8)
- En passant

Available end game conditions are:

- Checkmate
- Stalemate
- Player Resigns
- Offer Draw
- Draw by fifty-move rule (no pawn move or capture for fifty moves)
- Draw by insufficient material

Draw by three-fold repetition is not implemented.

I have left my 'planning.txt' file in the repo which I used throughout the project to record my thinking about the various problems along the way and some pseudocode.

# Code

The board is a 2D array `[[rows][colums]]`. White is at the 'bottom' of the board on row index 7, and black is at the 'top' of the board on row index 0.

Squares are represented as a row-column array pair. E.g. the square a8 is represented as [0, 0].

Moves are represented by an array. The `piece` is a one-character string, where uppercase is white, lowercase is black. E.g. white queen is 'Q', black knight is 'n'. The 'squares' are row-column array pairs.

```rb
[piece, [origin square], [destination square]]
```

E.g. the move 'e4' by white is represented as:

```rb
['P', [6, 4], [4, 4]]
```

The classes in use are:

|Class|Purpose|
|---|---|
|Chess|Manage the game loop|
|GameBoard|Move pieces|
|Player|Select moves|
|Pieces|Supply movement options|

Modules are used to extend the functionality of the classes.

The 'Convert' module is largely independent of its calling GameBoard class. Submodule TextToArray takes an algebraic move string as input and returns the move as an array (with disambiguation to a specific origin if a list of legal moves is provided). Submodule ArrayToText takes a move array as described above and converts it to an algebraic move, again with disambiguation included as necessary if a set of legal moves is provided.

The 'FileManager' module is also largely independent of calling classes - it saves and loads a hash of game data using a command-line interface and is otherwise unconcerned with the format of the data.

LegalMoves and its own module LegalCastlingMoves are very tightly coupled to the GameBoard class and are included as mixins.

# Required gems

None.
