// SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

enum Status {
    Open,
    InProgress,
    Closed
}

enum Symbol {
    nil,
    x,
    o,
    tie
}

struct Game {
    address owner;
    address player;
    Symbol[9] board;
    Status status;
    bool xIsNext;
    address winner;
}

contract TicTacToe {
    mapping(address => Game) public games;

    constructor() {}

    modifier validSender() {
        require(msg.sender != address(0), "Sender cannot be zero address");
        _;
    }

    modifier validOwner(address owner) {
        require(owner != address(0), "This address cannot be zero address");
        require(
            owner == games[owner].owner,
            "This address does not own any game"
        );
        _;
    }

    function newGame() public validSender {
        address owner = msg.sender;
        Symbol[9] memory board;
        games[owner] = Game({
            owner: owner,
            player: address(0),
            board: board,
            status: Status.Open,
            xIsNext: true,
            winner: address(0)
        });
    }

    function getGame(address owner) public view returns (Game memory game) {
        game = games[owner];
    }

    function joinGame(address owner) public validSender validOwner(owner) {
        assert(games[owner].status == Status.Open);
        games[owner].player = msg.sender;
        games[owner].status = Status.InProgress;
    }

    function nextTurn(address owner, uint8 number) public {
        assert(games[owner].status == Status.InProgress);
        assert(number < 9);
        Game storage game = games[owner];
        // nil: default x: owner o: player
        Symbol s;
        if (game.xIsNext) {
            assert(msg.sender == game.owner);
            s = Symbol.x;
        } else {
            assert(msg.sender == game.player);
            s = Symbol.o;
        }
        assert(game.board[number] == Symbol.nil);
        game.board[number] = s;
        Symbol w = checkWinner(game.board);
        if (w != Symbol.nil) {
            game.status = Status.Closed;
            if (w != Symbol.tie) {
                game.winner = (w == Symbol.x) ? game.owner : game.player;
            }
        }
        game.xIsNext = !game.xIsNext;
    }

    function checkWinner(Symbol[9] memory board)
        internal
        pure
        returns (Symbol)
    {
        uint8[3][8] memory lines = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6]
        ];
        for (uint8 i = 0; i < lines.length; i++) {
            uint8[3] memory line = lines[i];
            Symbol a = board[line[0]];
            Symbol b = board[line[1]];
            Symbol c = board[line[2]];
            if (a != Symbol.nil && a == b && b == c) {
                return a;
            }
        }
        // tie if no empty space left
        for (uint8 i = 0; i < board.length; i++) {
            if (board[i] == Symbol.nil) {
                return Symbol.nil;
            }
        }
        return Symbol.tie;
    }

    function deleteGame(address owner) public {
        assert(msg.sender == owner);
        delete games[owner];
    }

    receive() external payable {
        revert();
    }
}
