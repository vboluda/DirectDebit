pragma solidity ^0.7.0;

import "hardhat/console.sol";
import "./IDirectDebit.sol";
import "./DirectDebit.sol";

contract DirectDebitFactory is IDirectDebit{
    address payable globalOwner;

   //CONSTRUCTOR.
  constructor() {
    console.log("Deploying with owner:", msg.sender);
    globalOwner=msg.sender;
  }

  mapping(address=>address) contracts;

  function getGlobalOwner() public view returns (address){
      return globalOwner;
  }

  function createNewDirectDebitContract() public{
      address  sender=msg.sender;
      address contractInstance=address(new DirectDebit());
      contracts[sender]=contractInstance;
      console.log("Created new contract Sender: '%s'  Contract address: '%s')", msg.sender, contractInstance);
  }

  function getContractAddress() public view returns(address){
      address  sender=msg.sender;
      return contracts[sender];
  }

  //Proxied functions


  function getOwner() override public view returns (address){
      IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

      return instance.getOwner();
  }

  function getAllowed(address recipient) override public view returns (bool _isAllowed, uint _maxAmmount){
      IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

      return instance.getAllowed(recipient);
  }
  
  function allow(address recipient, uint _maxAmount) override public{
      IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

      instance.allow(recipient, _maxAmount);

  }

  function deny(address recipient) override public{
      IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

      instance.deny(recipient);
  }
   
   function getBalance() override public view returns(uint){
       IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

       return instance.getBalance();
   }
   
   function returnFunds(uint amount) override public{
       IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

       instance.returnFunds(amount);
   }
   
   function addOrder(
    address recipient, 
    uint document_identifier,
    bytes32 document_hash,
    uint amount
    ) override public{
        IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

        instance.addOrder(recipient, document_identifier, document_hash, amount);
    }

   function getOrder(address recipient, uint document_identifier) override public view
    returns(
        bytes32 document_hash,
        uint amount,
        uint validated_validated
    ){
        IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

        bytes32 rdocument_hash;
        uint ramount;
        uint rvalidated_validated;

        (rdocument_hash,ramount,rvalidated_validated)=instance.getOrder(recipient, document_identifier);
        return(
            rdocument_hash,
            ramount,
            rvalidated_validated
        );
    }
    function orderAprobal(address payable recipient, uint document_identifier) 
    override public{
        IDirectDebit instance=IDirectDebit(contracts[msg.sender]);

        instance.orderAprobal(recipient, document_identifier);
    }

}