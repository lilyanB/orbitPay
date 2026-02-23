// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {OrbitPay} from "../src/OrbitPay.sol";

contract OrbitPayScript is Script {
    OrbitPay public orbitPay;

    address public constant USDC = 0x6e13B503bE2d289dfE762ef29A3b19377946236b;
    address public constant USDT = 0xd2ECba4dFaE14CcE2d2e767974C01532C1f7EA07;
    address public constant WETH = 0x40e43BE2fEaf21cB459C4f493c14F0ad4A0E3451;

    function run(address owner) public {
        vm.startBroadcast();

        orbitPay = new OrbitPay(owner, USDC, USDT, WETH, owner);

        vm.stopBroadcast();
    }
}
