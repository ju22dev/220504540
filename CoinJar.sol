// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract CoinJar {
    address payable private owner;
    uint256 private triggerTime;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() external payable {
        require(msg.value > 0.0001 ether, "You must send min. 0.0001 ETH!");
        triggerTime = block.timestamp + 1 minutes;
    }

    function withdraw() external {
        require(block.timestamp > triggerTime, "Too early to withdraw.");
        require(owner == msg.sender, "You must be the owner to withdraw.");
        payable(owner).transfer(address(this).balance);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    } 
}

