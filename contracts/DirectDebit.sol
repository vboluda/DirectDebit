//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";


contract DirectDebit {
  address payable owner;

  struct allowed {
    bool isAllowed;
    uint maxAmount; // max ammount can this recipient can order
  }

  mapping (address => allowed) allowedRecipients;

  struct directDebitOrder{
    //uint document_identifier; // Recipient document identifier for identfication purposes
    bytes32 document_hash; // Recipient document hash for validation purposes
    uint amount; // Ammount to pay 
    uint validated_block; // block where has been validated by owner or 0 if it has not
  }
  mapping(address => mapping(uint => directDebitOrder)) orders;

  modifier restrictedToOwner() {
    require(
      msg.sender == owner,
      "Not authorized. Owner is required"
    );
    _;
  }

  constructor() {
    console.log("Deploying with owner:", msg.sender);
    owner=msg.sender;
  }

  function finalize() public restrictedToOwner  {
    selfdestruct(owner);
  }

  function getOwner() public view returns (address){
    return owner;
  }

  function getAllowed(address recipient) public view 
    returns(bool _isAllowed, uint _maxAmmount){
      console.log("getAllowed ", recipient);
      allowed memory _allowed;
      _allowed=allowedRecipients[recipient];
      return (
        _allowed.isAllowed,
        _allowed.maxAmount
      );
    }

    function allow(address recipient, uint _maxAmount) public restrictedToOwner {
      console.log("allow ('%s',  '%i')", recipient, _maxAmount);
      allowedRecipients[recipient].isAllowed=true;
      allowedRecipients[recipient].maxAmount=_maxAmount;
    }

    function deny(address recipient) public restrictedToOwner {
      console.log("deny ", recipient);
      allowedRecipients[recipient].isAllowed=false;
    }

  fallback() external payable {
    console.log("Recibed by fallback", msg.value);
  }

  receive() external payable {
        console.log("Recibed ", msg.value);
  }

  function getBalance() public view returns(uint){
    console.log("Get Balance");
    return address(this).balance;
  }

  function returnFunds(uint amount) public restrictedToOwner{
    console.log("ReturnFunds ",amount);
    require(amount <= getBalance(),
    "not enoght funds");
    owner.transfer(amount);//not send to avoid reentrancy issues
    console.log("Funds in contract ",getBalance());
  }

  function addOrder(
    address recipient, 
    uint document_identifier,
    bytes32 document_hash,
    uint amount
    ) public{

      require(allowedRecipients[recipient].isAllowed,"Not Allowed recipient");
      require(allowedRecipients[recipient].maxAmount>=amount,
        "Amount exceeds max amount allowed for this recipient");
      directDebitOrder storage order;
      order=orders[recipient][document_identifier];
      require(order.validated_block==0,"Trying to modifify a processed order");
      order.document_hash=document_hash;
      order.amount=amount;
      order.validated_block=block.number;
    }

  function getOrder(address recipient, uint document_identifier) public view
  returns(
    bytes32 document_hash,
    uint amount,
    uint validated_validated
  ){
    directDebitOrder memory order;
    order=orders[recipient][document_identifier];
    return(
      order.document_hash,
      order.amount,
      order.validated_block
    );
  }
  
}