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
    address public owner;
    address public factory;

    function setUp() public virtual {
        cre = makeAddr("CRE");
        owner = makeAddr("OWNER");
        factory = makeAddr("FACTORY");
        usdc = new ERC20Mock("USDC", "USDC", 6);
        usdt = new ERC20Mock("USDT", "USDT", 6);
        weth = new ERC20Mock("WETH", "WETH", 18);
        orbitPay = new OrbitPay(owner, address(usdc), address(usdt), address(weth), factory, cre);
    }
}
