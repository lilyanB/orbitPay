// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";

import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";

contract MocksScript is Script {
    function run() external returns (IERC20 usdt_, IERC20 usdc_, IERC20 weth_) {
        vm.startBroadcast();

        usdc_ = IERC20(address(new ERC20Mock("USD Coin", "USDC", 6)));
        usdt_ = IERC20(address(new ERC20Mock("Tether USD", "USDT", 6)));
        weth_ = IERC20(address(new ERC20Mock("Wrapped Ether", "WETH", 18)));

        vm.stopBroadcast();
    }
}
