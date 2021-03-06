//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";

/***************************************** DirectDebit  ***********************************************
Contract for direct debit of recurring payments in the same way as in a traditional bank
Service providers who have permissions may include payment orders in this contract. 
If the owner agrees, will approve the order and transfer the amount of the payment to the supplier.
*/
contract DirectDebit {
  //CONTRACT OWNER
  address payable owner;

  //EVENT TRIGGERED WHEN NEW ORDER HAS INCLUDED IN CONTRACT
  event newOrderEvnt(address recipient, uint document_identifier, bytes32 document_hash, uint amount);
  //EVENT TRIGGERED WHEN AN ORDER HAS BEEN APPROVED
  event orderAprovalEvnt(address recipient, uint document_identifier, bytes32 document_hash, uint amount,uint validated_block);

  //STRUCTURE WHICH CONTAINS RECIPIENTS ALLOWED TO INCLUDER PAYMENT ORDERS
  struct allowed {
    bool isAllowed;
    uint maxAmount; // max ammount can this recipient can order
  }

  //STRUCTURE WHICH CONTAINS RECIPIENTS ALLOWED TO INCLUDER PAYMENT ORDERS
  mapping (address => allowed) allowedRecipients;

  //STRUCTURE WHICH CONTAINS ORDERS
  struct directDebitOrder{
    //uint document_identifier; // Recipient document identifier for identfication purposes
    bytes32 document_hash; // Recipient document hash for validation purposes
    uint amount; // Ammount to pay 
    uint validated_block; // block where has been validated by owner or 0 if it has not
  }
  //STRUCTURE WHICH CONTAINS ORDERS
  mapping(address => mapping(uint => directDebitOrder)) orders;

  //MODIFIER TO ENSURE ONLY OWNER CAN CALL THESE FUNCTIONS
  modifier restrictedToOwner() {
    require(
      msg.sender == owner,
      "Not authorized. Owner is required"
    );
    _;
  }

  //CONSTRUCTOR.
  constructor() {
    console.log("Deploying with owner:", msg.sender);
    owner=msg.sender;
  }

  //DESTRUCTOR EN CASE NEEDED. HANDLE WITH CARE!!!
  function finalize() public restrictedToOwner  {
    selfdestruct(owner);
  }

   //PUBLIC GETTER FOR OWNER
  function getOwner() public view returns (address){
    return owner;
  }

  //PUBLIC FUNCTION TO VERIFY IF A RECIPIENT CAN INCLUDE ORDERS IN THIS CONTRACT, AND MAXIMUM AMOUNT
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

    //PUBLIC FUNCTION TO ADD A NEW RECIPIENT GRANTED TO ADD ORDERS TO SMART CONTRACT
    function allow(address recipient, uint _maxAmount) public restrictedToOwner {
      console.log("allow ('%s',  '%i')", recipient, _maxAmount);
      allowedRecipients[recipient].isAllowed=true;
      allowedRecipients[recipient].maxAmount=_maxAmount;
    }

    //PUBLIC FUNCTION TO PREVENT A RECIPIENT FOR INCLUDING NEW ORDERS
    function deny(address recipient) public restrictedToOwner {
      console.log("deny ", recipient);
      allowedRecipients[recipient].isAllowed=false;
    }

  //FALLBACK
  fallback() external payable {
    console.log("Recibed by fallback", msg.value);
  }

  // TO TRANSFER FUNDS TO THIS CONTRACT. CALL DIRECTLY TO CONTRACT WITH NO FUNCTION
  receive() external payable {
        console.log("Recibed ", msg.value);
  }

  // GETTER FOR CONTRACT BALANCE
  function getBalance() public view returns(uint){
    console.log("Get Balance");
    return address(this).balance;
  }

  //IN CASE NEEDED OWNER CAN WITHDRAW FUNDS FROM THIS CONTRACT. IT IS ITS MONEY
  function returnFunds(uint amount) public restrictedToOwner{
    console.log("ReturnFunds ",amount);
    require(amount <= getBalance(),
    "not enought funds");
    owner.transfer(amount);//not send to avoid reentrancy issues
    console.log("Funds in contract ",getBalance());
  }

  //PLACE AN ORDER TO ORDER BOOK WAITING TO BE VALIDATED FROM OWNER
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
      emit newOrderEvnt( recipient,  document_identifier,  document_hash,  amount);
    }

  //GET ORDER DETAILS FROM RECIPIENT ADDRESS AND DOCUMENT IDENTIFIER
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

  //OWNER IF AGREES CAN APROVE PAYMENT ORDER THIS WILL DISABLE THIS ORDER AN CAUSE FUNDS TO BE TRANSFERED TO 
  //   RECIPIENT ADDRESS
  function orderAprobal(address payable recipient, uint document_identifier) public restrictedToOwner{
    directDebitOrder storage order=orders[recipient][document_identifier];
    require(order.amount <=getBalance(),"No enought funds to accept this order");
    require(order.validated_block == 0 ,"Cannot accept: Order Previously accepted");
    //CHANGE VALIDATION TO FALSE BEFORE SENDING FUNDS TO AVOID REENTRANCY IN CASE ADDRESS BELONGS TO A CONTRACT
    order.validated_block=block.number;
    //USE TRANSFER TO ENSURE THIS TX WON'T HAS ENOUGHT GAS TO EXECUTE ANY CODE; JUST TRANSFER FUNDS.
    recipient.transfer(order.amount);
    emit orderAprovalEvnt( recipient,  document_identifier,  order.document_hash,  order.amount, order.validated_block);
  }
  
}