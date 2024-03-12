////&// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";


contract DirectDebitFactory is Ownable, Pausable{

    address public debitImplementation;
    address public lastCreated;

    event DirectDebitCreated(address indexed debitAddress, address indexed owner,bytes32 indexed identifier);


    constructor(address _debitImplementation) Ownable(_msgSender())
    {
        debitImplementation = _debitImplementation;
    }

    function cloneContract(bytes32 identifier) external whenNotPaused {
        address clone = Clones.cloneDeterministic(debitImplementation, identifier);
        lastCreated = clone;
        emit DirectDebitCreated(clone, _msgSender(),identifier);
    }

    function setDebitImplementation(address _debitImplementation) external onlyOwner whenNotPaused{
        debitImplementation = _debitImplementation;
    }

    function pause() public onlyOwner whenNotPaused{
        _pause();
    }

    function unpause() public onlyOwner whenPaused{
        _unpause();
    }

    function getContract(bytes32 identifier) public view returns (address) {
        return Clones.predictDeterministicAddress(debitImplementation, identifier);
    }
}
