// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract lottery {
    address public manager;
    address payable[] public players;

    constructor() {
        manager = msg.sender;
    }

    function alreadyEntered() private view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function participate() public payable {
        require(msg.sender != manager, "Manager can't participate.");
        require(alreadyEntered() == false, "Player already participated.");
        require(msg.value >= 1 ether, "Minimum 1 ether must be payed.");
        players.push(payable(msg.sender));
    }

    function random() private view returns (uint) {
        return (
            uint(
                sha256(
                    abi.encodePacked(block.prevrandao, block.number, players)
                )
            )
        );
    }

    function pickWinner() public {
        require(msg.sender == manager, "Only manager can pick the winner");
        uint randomIndex = random() % players.length; //index of winner
        address contractAddress = address(this);
        players[randomIndex].transfer(contractAddress.balance);
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getWinner() public view returns (address) {
        require(msg.sender == manager, "Only manager can get the winner");
        require(players.length > 0, "No players participated");
        uint randomIndex = random() % players.length;
        return players[randomIndex];
    }
}
