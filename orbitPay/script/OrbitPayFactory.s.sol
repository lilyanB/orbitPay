// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {OrbitPayFactory} from "../src/OrbitPayFactory.sol";

contract OrbitPayFactoryScript is Script {
    OrbitPayFactory public orbitPay;

    address public constant USDC = 0x6e13B503bE2d289dfE762ef29A3b19377946236b;
    address public constant USDT = 0xd2ECba4dFaE14CcE2d2e767974C01532C1f7EA07;
    address public constant WETH = 0x40e43BE2fEaf21cB459C4f493c14F0ad4A0E3451;

    function run(address owner) public returns (OrbitPayFactory orbitPay_) {
        vm.startBroadcast();

        orbitPay_ = new OrbitPayFactory(owner, USDC, USDT, WETH);

        vm.stopBroadcast();
    }
}
