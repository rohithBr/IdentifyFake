pragma solidity >=0.4.24;
// SPDX-License-Identifier: MIT

import "./Roles.sol";

contract RetailerRole {
    using Roles for Roles.Role;

    event RetailerAdded(address indexed account);
    event RetailerRemoved(address indexed account);

    Roles.Role private Retailers;

    modifier onlyRetailer() {
        require(isRetailer(msg.sender));
        _;
    }

    constructor() {
        _addRetailer(msg.sender);
    }

    function addRetailer() public {
        _addRetailer(msg.sender);
    }

    function renounceRetailer() public {
        _removeRetailer(msg.sender);
    }

    function isRetailer(address account) public view returns (bool) {
        return Retailers.has(account);
    }

    function _addRetailer(address account) internal {
        Retailers.add(account);
        emit RetailerAdded(account);
    }

    function _removeRetailer(address account) internal {
        Retailers.remove(account);
        emit RetailerRemoved(account);
    }
}