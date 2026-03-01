// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {OrbitPay} from "../src/OrbitPay.sol";

contract OrbitPayScript is Script {
    OrbitPay public orbitPay;

    address public constant USDC = 0x23a0485b021CA24efde51114823FDbA761359780;
    address public constant USDT = 0xa0a5a661f7fad0E1F5B5a9C479de51eEEf4D1223;
    address public constant WETH = 0x260B90dFf3F586B1141790a212D7437D5521d5B8;
    address public constant CRE = 0x15fC6ae953E024d975e77382eEeC56A9101f9F88;

    function run(address owner) public {
        vm.startBroadcast();

        orbitPay = new OrbitPay(owner, USDC, USDT, WETH, owner, CRE);

        vm.stopBroadcast();
    }
}
