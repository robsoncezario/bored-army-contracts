// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoredArmyToken is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("Bored Army Token", "BAT") public {
        _mint(msg.sender, initialSupply);
    }
}