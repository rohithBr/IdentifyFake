pragma solidity >=0.4.24;

// SPDX-License-Identifier: MIT

library Roles {
    struct Role {
        mapping(address => bool) isParticipants;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {
        require(account != address(0));
        return role.isParticipants[account];
    }

    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));
        role.isParticipants[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.isParticipants[account] = false;
    }
}