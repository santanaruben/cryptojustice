// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.24 < 0.7.0;

import "./interfaces/OwnedI.sol";

contract Owned is OwnedI{

    address private _owner;
    
    constructor () public {
        _owner = msg.sender;
    }

    modifier fromOwner() {
        require(msg.sender == _owner, "Not the owner");
        _;
    }

    function setOwner(address newOwner) public returns (bool success) {
        address oldOwner = _owner;
        require(msg.sender == oldOwner, "Not the owner");
        require(newOwner != address(0), "Contract need an owner");
        require(newOwner != oldOwner, "Same owner");
        _owner = newOwner;
        emit LogOwnerSet(oldOwner, newOwner);
        success = true;
    }

    function getOwner() public view returns (address owner) {
        owner = _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}
