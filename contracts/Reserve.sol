//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Reserve {

  address payable owner;

  event Received(address sender, uint amount);
  event WithdrawSuccess(address receiver, uint amount);

  constructor() {
    owner = payable(msg.sender);
  }

  receive() external payable {
    emit Received(msg.sender, msg.value);
  }

  function withdraw() external {
    require(msg.sender == owner, "Only owner can withdraw");

    uint amountPaid = address(this).balance;

    payable(msg.sender).transfer(amountPaid);
    emit WithdrawSuccess(msg.sender, amountPaid);
  }
}