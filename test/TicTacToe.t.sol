// SPDX-License-Identifier: MIT
pragma solidity =0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {TicTacToe, Game, Status, Symbol} from "../src/TicTacToe.sol";

contract TicTacToeTest is Test {
    TicTacToe tic;
    address owner;
    address player;
    uint256 ownerPrivateKey;
    uint256 playerPrivateKey;

    function setUp() public {
        tic = new TicTacToe();
        ownerPrivateKey = 0xA11CE;
        playerPrivateKey = 0xB0B;
        owner = vm.addr(ownerPrivateKey);
        player = vm.addr(playerPrivateKey);
    }

    function test_NewGame() public {
        vm.prank(owner);
        tic.newGame();
        assertEq(owner, tic.getGame(owner).owner);
    }

    function test_JoinGame() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        assertEq(player, tic.getGame(owner).player);
    }

    function test_NextTurnOwner() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        assertTrue(Symbol.x == tic.getGame(owner).board[0]);
    }

    function test_RevertNextTurnWrongPlayer() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn, so expect to revert here
        vm.expectRevert();
        vm.prank(player);
        tic.nextTurn(owner, 0);
    }

    function test_NextTurnPlayer() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 1);
        assertTrue(Symbol.o == tic.getGame(owner).board[1]);
    }

    function test_RevertNextTurnOverlap() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        // overlap number, so expect to revert here
        vm.expectRevert();
        vm.prank(player);
        tic.nextTurn(owner, 0);
    }

    function test_CheckWinnerIsOwner() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 3);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 1);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 4);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 2);
        assertEq(owner, tic.getGame(owner).winner);
    }

    function test_CheckWinnerIsPlayer() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 3);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 0);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 4);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 1);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 6);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 2);
        assertEq(player, tic.getGame(owner).winner);
    }

    function test_RevertNextTurnGameClosed() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 3);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 1);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 4);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 2);
        // owner already won, so expect to revert here
        vm.expectRevert();
        vm.prank(player);
        tic.nextTurn(owner, 5);
    }

    function test_CheckGameIsTie() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(player);
        tic.joinGame(owner);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 0);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 4);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 8);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 2);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 6);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 3);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 5);
        // player's turn
        vm.prank(player);
        tic.nextTurn(owner, 7);
        // owner's turn
        vm.prank(owner);
        tic.nextTurn(owner, 1);
        // Tie if game is closed and winner is zero
        assertTrue(Status.Closed == tic.getGame(owner).status);
        assertEq(address(0), tic.getGame(owner).winner);
    }

    function test_DeleteGame() public {
        vm.prank(owner);
        tic.newGame();
        vm.prank(owner);
        tic.deleteGame(owner);
        assertEq(address(0), tic.getGame(owner).owner);
    }
}
