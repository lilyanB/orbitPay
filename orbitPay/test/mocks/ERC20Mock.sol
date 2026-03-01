// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin-contracts-5/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    uint8 public decimals_;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol) {
        decimals_ = _decimals;
        _mint(0x607A577659Cad2A2799120DfdEEde39De2D38706, 100 ether);
    }

    function decimals() public view override returns (uint8) {
        return decimals_;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
