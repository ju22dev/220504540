// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract SC220504540 {
    address payable private immutable owner;

    struct Account {
        address payable wallet;
        uint256 balance; // always in wei because msg.value is in wei
        uint256 triggerTime; // re-sets everytime a deposit is made
    }

    mapping(address => uint256) private accountIndex;
    Account[] private accounts;


    constructor() {
        owner = payable(msg.sender);
        accounts.push(Account(payable(address(0)), 0, 0));
        accountIndex[address(0)] = 0;
        accounts.push(Account(payable(msg.sender), 0, block.timestamp));
        accountIndex[msg.sender] = 1;
    }

    function deposit() external payable returns (string memory) {
        require(msg.value >= 0.0001 ether, "Minimum deposit is 0.0001 ETH");

        // create account if it doesn't exist
        uint idx = accountIndex[msg.sender];
        if (idx == 0 ) {
            accounts.push(Account(payable(msg.sender), msg.value, block.timestamp + 1 minutes));
            accountIndex[msg.sender] = accounts.length - 1;
            return "First deposit successful";
        }

        Account storage acc = accounts[idx];
        acc.balance += msg.value;
        acc.triggerTime = block.timestamp + 1 minutes;

        return "Deposit confirmed!";
    }

    function withdraw(uint amount) external {
        uint256 idx = accountIndex[msg.sender];
        require(idx < accounts.length && idx != 0, "Account not found");

        Account storage acc = accounts[idx];
        require(block.timestamp > acc.triggerTime, "Too early to withdraw");
        require(acc.balance > 0, "No balance");

        amount = amount * 1 ether;
        require(amount <= acc.balance, "Insufficient fund");
        acc.balance -= amount;
        acc.wallet.transfer(amount);
    }

    function ownerClaim(uint idx) external {
        // owner can inherit dead accounts with some balance in them
        require(msg.sender == owner, "Only owner can claim");
        require(idx < accounts.length && idx != 0, "Account not found");

        Account storage acc = accounts[idx];
        require(block.timestamp > acc.triggerTime + 2 minutes, "Grace period not over");
        require(acc.balance > 0, "No balance");

        uint256 amount = acc.balance;
        acc.balance = 0;

        owner.transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        uint256 idx = accountIndex[msg.sender];
        require(idx < accounts.length && idx != 0, "Account not found");

        Account storage acc = accounts[idx];

        return acc.balance;
    }

}
