//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";


contract DirectDebit {
  address owner;

  struct allowed {
    bool isAllowed;
    uint maxAmount; // max ammount can this recipient can order
  }

  mapping (address => allowed) allowedRecipients;

  struct directDebitOrder{
    address recipient; // Who has include paiment order
    uint document_identifier; // Recipient document identifier for identfication purposes
    bytes32 document_hash; // Recipient document hash for validation purposes
    uint amount; // Ammount to pay 
    uint validated_block; // block where has been validated by owner or 0 if it has not
    bool isValidated; // If has been validated and payed
  }

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
  
}