//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Staker {
    address owner;

    mapping(address => uint256) balances;

    struct HighestBid {
        address bidAddress;
        uint256 amount;
    }

    HighestBid highestBidder;

    uint256 duration = 2 days;
    uint256 deadline;

    uint256 threshold = 5 ether;

    address payable receivingContractAddress;

    event StakeSuccess(address sender, uint256 amount);
    event CompleteSuccess(address receiver, uint256 amount);
    event WithdrawSuccess(address receiver, uint256 amount);
    event DidNotMeetThreshold(string message);

    constructor(address reserve) {
        deadline = block.timestamp + duration;
        receivingContractAddress = payable(reserve);

        owner = msg.sender;
    }

    function stake() external payable {
        require(block.timestamp < deadline, "Deadline for staking is past");
        require(msg.value > 0, "Need to stake an amount");


        balances[msg.sender] = msg.value + balances[msg.sender];

        if (balances[msg.sender] > highestBidder.amount) {
            highestBidder.bidAddress = msg.sender;
            highestBidder.amount = balances[msg.sender];
        }

        emit StakeSuccess(msg.sender, msg.value);
    }

    function complete() external {
        require(block.timestamp < deadline, "Staking has ended already");
        require(msg.sender == owner, "You don't have enough priviledge for this action");

        if (address(this).balance >= threshold) {
            uint256 valueSent = address(this).balance;

            receivingContractAddress.transfer(address(this).balance);
            emit CompleteSuccess(receivingContractAddress, valueSent);
        } else {
          emit DidNotMeetThreshold("Bid did not meet goal");
        }

        deadline = block.timestamp;
    }

    function withdraw() external {
        //TODO: change to mnemonics
        require(block.timestamp > deadline, "Staking is still ongoing");
        require(balances[msg.sender] > 0, "Didn't stake any amount");

        uint256 paidAmount = balances[msg.sender];
        balances[msg.sender] = 0;

        payable(msg.sender).transfer(paidAmount);
        emit WithdrawSuccess(msg.sender, paidAmount);
    }

    function getHighestBidder() external view returns (address, uint256) {
        return (highestBidder.bidAddress, highestBidder.amount);
    }

    function getDeadline() external view returns (uint256) {
        return deadline;
    }

    function getThreshold() external view returns (uint256) {
        return threshold;
    }
}
