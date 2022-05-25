pragma solidity >=0.4.24;
// SPDX-License-Identifier: MIT

import "./Roles.sol";

contract ConsumerRole {
    using Roles for Roles.Role;

    event ConsumerAdded(address indexed account);
    event ConsumerRemoved(address indexed account);

    Roles.Role private Consumers;

    modifier onlyConsumer() {
        require(isConsumer(msg.sender));
        _;
    }

    constructor() {
        _addConsumer(msg.sender);
    }

    function addConsumer() public {
        _addConsumer(msg.sender);
    }

    // Define a function 'renounceConsumer' to renounce this role
    function renounceConsumer() public {
        _removeConsumer(msg.sender);
    }

    function isConsumer(address account) public view returns (bool) {
        return Consumers.has(account);
    }

    function _addConsumer(address account) internal {
        Consumers.add(account);
        emit ConsumerAdded(account);
    }

    function _removeConsumer(address account) internal {
        Consumers.remove(account);
        emit ConsumerRemoved(account);
    }
}