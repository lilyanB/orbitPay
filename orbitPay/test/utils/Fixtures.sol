// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {OrbitPay} from "../../src/OrbitPay.sol";

contract OrbitPayFixture is Test {
    ERC20Mock public usdc;
    ERC20Mock public usdt;
    ERC20Mock public weth;
    OrbitPay public orbitPay;
    address public cre;

    function setUp() public virtual {
        cre = address(0x1);
        usdc = new ERC20Mock("USDC", "USDC", 6);
        usdt = new ERC20Mock("USDT", "USDT", 6);
        weth = new ERC20Mock("WETH", "WETH", 18);
        orbitPay = new OrbitPay(address(usdc), address(usdt), address(weth), cre);
    }
}
