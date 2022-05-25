pragma solidity >=0.4.24;
// SPDX-License-Identifier: MIT

import "./Roles.sol";

contract ManufacturerRole {
    using Roles for Roles.Role;

    event ManufacturerAdded(address indexed account);
    event ManufacturerRemoved(address indexed account);

    Roles.Role private Manufacturers;

    modifier onlyManufacturer() {
        require(isManufacturer(msg.sender));
        _;
    }

    constructor() {
        _addManufacturer(msg.sender);
    }

    function addManufacturer() public {
        _addManufacturer(msg.sender);
    }

    // Define a function 'renounceManufacturer' to renounce this role
    function renounceManufacturer() public {
        _removeManufacturer(msg.sender);
    }

    function isManufacturer(address account) public view returns (bool) {
        return Manufacturers.has(account);
    }

    function _addManufacturer(address account) internal {
        Manufacturers.add(account);
        emit ManufacturerAdded(account);
    }

    function _removeManufacturer(address account) internal {
        Manufacturers.remove(account);
        emit ManufacturerRemoved(account);
    }
}