// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable-4.7.3/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable-4.7.3/access/OwnableUpgradeable.sol";

contract DirectDebitManager is OwnableUpgradeable {

    uint256 constant A_DAY = 86400;
    uint256 constant A_MONTH = A_DAY * 30;

    struct DirectDebitType{
        address collector;
        uint256 maximumAmount;
        uint256 minimumPeriod;
        bool active;
    }

    struct DebitOrder {
        uint256 amount;
        address collector;
        bool requiresApproval;
        bool paid;
        uint256 timestamp;
        bytes32 invoiceHash;
    }

    event DirectDebitTypeEvent(address indexed collector, uint256 maximumAmount, uint256 minimumPeriod, bool active);

    event OrderCreated(uint256 orderId, address collector, uint256 amount, uint256 frequency, bytes32 invoiceHash);
    event PaymentRequested(uint256 orderId, address collector, uint256 amount);
    event PaymentApproved(uint256 orderId, uint256 amount);
    event PaymentCompleted(uint256 orderId, uint256 amount);

    mapping(address => DirectDebitType) public types;

    mapping(uint256 => DebitOrder) public orders;
    uint256 public nextOrderId;

    
    




    






    // Crear una nueva orden de domiciliación
    function createOrder(uint256 amount, uint256 frequency, address collector, bytes32 invoiceHash) external onlyOwner {
        orders[nextOrderId] = DebitOrder({
            amount: amount,
            frequency: frequency,
            lastPaymentTime: 0,
            collector: collector,
            requiresApproval: false,
            paid: false,
            invoiceHash: invoiceHash
        });
        emit OrderCreated(nextOrderId, collector, amount, frequency, invoiceHash);
        nextOrderId++;
    }

    // Solicitar un pago para una orden de domiciliación específica
    function requestPayment(uint256 orderId, uint256 amount) external {
        DebitOrder storage order = orders[orderId];
        require(msg.sender == order.collector, "Caller is not the collector");
        require(!order.paid, "Order already paid");
        require(block.timestamp >= order.lastPaymentTime + order.frequency, "Payment frequency not met");
        
        if(amount > order.amount || block.timestamp < order.lastPaymentTime + order.frequency) {
            order.requiresApproval = true;
            emit PaymentRequested(orderId, msg.sender, amount);
        } else {
            order.lastPaymentTime = block.timestamp;
            order.paid = true;
            // Lógica para transferir los tokens desde el contrato al cobrador
            emit PaymentCompleted(orderId, amount);
        }
    }

    // Aprobar un pago pendiente
    function approvePayment(uint256 orderId) external onlyOwner {
        DebitOrder storage order = orders[orderId];
        require(order.requiresApproval, "Order does not require approval");

        order.lastPaymentTime = block.timestamp;
        order.requiresApproval = false;
        order.paid = true;
        // Lógica para transferir los tokens desde el contrato al cobrador

        emit PaymentApproved(orderId, order.amount);
    }

    // Depositar tokens ERC20 en el contrato
    function depositTokens(IERC20 token, uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    // Retirar tokens ERC20 del contrato
    function withdrawTokens(IERC20 token, uint256 amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }
}
