pragma solidity ^0.7.0;

interface IDirectDebit {
   function getOwner() external view returns (address);
   function getAllowed(address recipient) external view 
    returns(bool _isAllowed, uint _maxAmmount);
   function allow(address recipient, uint _maxAmount) external;
   function deny(address recipient) external;
   function getBalance() external view returns(uint);
   function returnFunds(uint amount) external;
   function addOrder(
    address recipient, 
    uint document_identifier,
    bytes32 document_hash,
    uint amount
    ) external;
   function getOrder(address recipient, uint document_identifier) external view
    returns(
        bytes32 document_hash,
        uint amount,
        uint validated_validated
    );
    function orderAprobal(address payable recipient, uint document_identifier) external;
}