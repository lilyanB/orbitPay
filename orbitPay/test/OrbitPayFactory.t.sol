// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

import {OrbitPay} from "../src/OrbitPay.sol";
import {OrbitPayFactory} from "../src/OrbitPayFactory.sol";
import {IOrbitPay} from "../src/interfaces/IOrbitPay.sol";
import {IOrbitPayFactory} from "../src/interfaces/IOrbitPayFactory.sol";

/**
 * @custom:feature The core functionality of the `OrbitPayFactory` contract
 * @custom:background A newly deployed OrbitPayFactory contract with initialized token contracts
 */
contract TestOrbitPayFactory is Test {
    ERC20Mock public usdc;
    ERC20Mock public usdt;
    ERC20Mock public weth;
    OrbitPayFactory public factory;
    address public owner;

    function setUp() public {
        owner = makeAddr("OWNER");
        usdc = new ERC20Mock("USDC", "USDC", 6);
        usdt = new ERC20Mock("USDT", "USDT", 6);
        weth = new ERC20Mock("WETH", "WETH", 18);
        factory = new OrbitPayFactory(owner, address(usdc), address(usdt), address(weth));
    }

    /* -------------------------------------------------------------------------- */
    /*                               Constructor                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test immutable token addresses and owner
     * @custom:when The factory is deployed
     * @custom:then The immutable token addresses should be correctly set
     * @custom:and The owner should be correctly set
     */
    function test_immutableAddresses() external view {
        assertEq(address(factory.USDC()), address(usdc), "USDC address correct");
        assertEq(address(factory.USDT()), address(usdt), "USDT address correct");
        assertEq(address(factory.WETH()), address(weth), "WETH address correct");
        assertEq(factory.owner(), owner, "owner correct");
    }

    /* -------------------------------------------------------------------------- */
    /*                              getOrbitPayId                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test getOrbitPayId returns zero before any OrbitPay is created
     * @custom:when No OrbitPay has been created
     * @custom:then The next ID should be 0
     */
    function test_getOrbitPayIdInitial() external view {
        assertEq(factory.getOrbitPayId(), 0, "initial orbitPayId is 0");
    }

    /* -------------------------------------------------------------------------- */
    /*                              getOrbitPay                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test getOrbitPay returns address(0) for non-existent ID
     * @custom:when Querying an OrbitPay address for an ID that has not been created
     * @custom:then The returned address should be address(0)
     */
    function test_getOrbitPayNonExistentId() external view {
        assertEq(factory.getOrbitPay(0), address(0), "non-existent orbitPay returns address(0)");
        assertEq(factory.getOrbitPay(999), address(0), "large non-existent id returns address(0)");
    }

    /* -------------------------------------------------------------------------- */
    /*                             createOrbitPay                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test createOrbitPay deploys a new OrbitPay and emits an event
     * @custom:when createOrbitPay is called with an owner address
     * @custom:then A new OrbitPay should be deployed with correct token addresses and factory
     * @custom:and The OrbitPay should be stored at ID 0
     * @custom:and The next ID should be incremented to 1
     * @custom:and A CreatedOrbitPay event should be emitted
     */
    function test_createOrbitPay() external {
        address orbitPayOwner = makeAddr("ORBITPAY_OWNER");
        address expectedAddr = vm.computeCreateAddress(address(factory), 1);

        vm.expectEmit();
        emit IOrbitPayFactory.CreatedOrbitPay(0, expectedAddr);
        IOrbitPay orbitPay = factory.createOrbitPay(orbitPayOwner);

        assertEq(address(orbitPay), expectedAddr, "deployed at expected address");
        assertEq(factory.getOrbitPayId(), 1, "orbitPayId incremented to 1");
        assertEq(factory.getOrbitPay(0), address(orbitPay), "stored at ID 0");

        assertEq(OrbitPay(address(orbitPay)).owner(), orbitPayOwner, "owner set correctly");
        assertEq(address(OrbitPay(address(orbitPay)).USDC()), address(usdc), "USDC set correctly");
        assertEq(address(OrbitPay(address(orbitPay)).USDT()), address(usdt), "USDT set correctly");
        assertEq(address(OrbitPay(address(orbitPay)).WETH()), address(weth), "WETH set correctly");
        assertEq(OrbitPay(address(orbitPay)).FACTORY(), address(factory), "FACTORY set correctly");
    }

    /**
     * @custom:scenario Test createOrbitPay can be called multiple times
     * @custom:when createOrbitPay is called twice with different owners
     * @custom:then Two distinct OrbitPay contracts should be deployed
     * @custom:and Each should be stored at its respective ID
     * @custom:and The next ID should be incremented to 2
     */
    function test_createOrbitPayMultiple() external {
        address owner1 = makeAddr("OWNER1");
        address owner2 = makeAddr("OWNER2");

        IOrbitPay orbitPay1 = factory.createOrbitPay(owner1);
        IOrbitPay orbitPay2 = factory.createOrbitPay(owner2);

        assertEq(factory.getOrbitPayId(), 2, "orbitPayId incremented to 2");
        assertEq(factory.getOrbitPay(0), address(orbitPay1), "orbitPay1 stored at ID 0");
        assertEq(factory.getOrbitPay(1), address(orbitPay2), "orbitPay2 stored at ID 1");
        assertTrue(address(orbitPay1) != address(orbitPay2), "distinct contract addresses");
    }

    /* -------------------------------------------------------------------------- */
    /*                           setCreInOrbitPay                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test setCreInOrbitPay sets the CRE address in an existing OrbitPay
     * @custom:when The owner calls setCreInOrbitPay with a valid ID and CRE address
     * @custom:then The CRE address should be set in the OrbitPay contract
     */
    function test_setCreInOrbitPay() external {
        address orbitPayOwner = makeAddr("ORBITPAY_OWNER");
        address cre = makeAddr("CRE");

        factory.createOrbitPay(orbitPayOwner);

        vm.prank(owner);
        factory.setCreInOrbitPay(0, cre);

        OrbitPay orbitPay = OrbitPay(factory.getOrbitPay(0));
        assertEq(orbitPay.CRE(), cre, "CRE set correctly");
    }

    /**
     * @custom:scenario Test revert when setCreInOrbitPay is called with an invalid ID
     * @custom:when The owner calls setCreInOrbitPay with an ID that has no OrbitPay
     * @custom:then The transaction reverts with `IOrbitPayFactoryInvalidOrbitPayId`
     */
    function test_revertWhen_setCreInOrbitPayInvalidId() external {
        address cre = makeAddr("CRE");

        vm.prank(owner);
        vm.expectRevert(IOrbitPayFactory.IOrbitPayFactoryInvalidOrbitPayId.selector);
        factory.setCreInOrbitPay(0, cre);
    }

    /**
     * @custom:scenario Test revert when non-owner calls setCreInOrbitPay
     * @custom:when A non-owner address calls setCreInOrbitPay
     * @custom:then The transaction reverts with an unauthorized error
     */
    function test_revertWhen_setCreInOrbitPayNotOwner() external {
        address orbitPayOwner = makeAddr("ORBITPAY_OWNER");
        address cre = makeAddr("CRE");
        address notOwner = makeAddr("NOT_OWNER");

        factory.createOrbitPay(orbitPayOwner);

        vm.prank(notOwner);
        vm.expectRevert();
        factory.setCreInOrbitPay(0, cre);
    }
}
