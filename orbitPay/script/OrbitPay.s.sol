// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {OrbitPay} from "../src/OrbitPay.sol";

contract OrbitPayScript is Script {
    OrbitPay public orbitPay;

    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant CRE = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function run(address owner) public {
        vm.startBroadcast();

        orbitPay = new OrbitPay(owner, USDC, USDT, WETH, CRE);

        vm.stopBroadcast();
    }
}
