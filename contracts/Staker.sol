//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Staker {

  mapping(address => uint256) balances;

  uint duration = 2 days;
  uint deadline;

  uint threshold = 5 ether;

  address payable receivingContractAddress;

  event StakeSuccess(address sender, uint amount);
  event CompleteSuccess(address receiver, uint amount);
  event WithdrawSuccess(address receiver, uint amount);

  constructor() {
    deadline = block.timestamp + duration;
  }

  function stake() external payable {
    require(block.timestamp < deadline, 'Deadline for staking is past');
    require(msg.value > 0, "Need to stake an amount");

    balances[msg.sender] = msg.value + balances[msg.sender];

    emit StakeSuccess(msg.sender, msg.value);
  }

  function complete() external {
    require(block.timestamp > deadline, 'Staking is still ongoing');
    require(address(this).balance >= threshold, 'Stake balance not up to threshold');

    uint valueSent = address(this).balance;

    receivingContractAddress.transfer(address(this).balance);
    emit CompleteSuccess(receivingContractAddress, valueSent);
  }

  function withdraw() external {
    //TODO: change to mnemonics
    require(block.timestamp > deadline, 'Staking is still ongoing');
    require(balances[msg.sender] > 0, "Didn't stake any amount");

    uint paidAmount = balances[msg.sender];
    balances[msg.sender] = 0;

    payable(msg.sender).transfer(paidAmount);
    emit WithdrawSuccess(msg.sender, paidAmount);
  }
}