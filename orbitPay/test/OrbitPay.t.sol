// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {OrbitPayFixture} from "./utils/Fixtures.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

import {OrbitPay} from "../src/OrbitPay.sol";
import {IOrbitPay} from "../src/interfaces/IOrbitPay.sol";

/**
 * @custom:feature The core functionality of the `OrbitPay` contract
 * @custom:background A newly deployed OrbitPay contract with initialized token contracts
 */
contract TestOrbitPay is OrbitPayFixture {
    uint256 constant INITIAL_BALANCE = 1e36;
    address user1 = address(0x2);
    address user2 = address(0x3);
    address user3 = address(0x4);

    function setUp() public override {
        super.setUp();

        usdc.mint(user1, INITIAL_BALANCE);
        usdc.mint(user2, INITIAL_BALANCE);
        usdc.mint(user3, INITIAL_BALANCE);

        usdt.mint(user1, INITIAL_BALANCE);
        usdt.mint(user2, INITIAL_BALANCE);
        usdt.mint(user3, INITIAL_BALANCE);

        weth.mint(user1, INITIAL_BALANCE);
        weth.mint(user2, INITIAL_BALANCE);
        weth.mint(user3, INITIAL_BALANCE);
    }

    /**
     * @dev Helper function to call onReport with encoded data
     */
    function _callOnReport(address[] memory users, uint256[] memory amounts) internal {
        bytes memory data = abi.encode(users, amounts);
        orbitPay.onReport("", data);
    }

    /* -------------------------------------------------------------------------- */
    /*                               Constructor                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test immutable token and factory addresses
     * @custom:when The contract is deployed
     * @custom:then The immutable token addresses should be correctly set
     * @custom:and The immutable FACTORY address should be correctly set
     * @custom:and The CRE address should be set after setCRE is called
     */
    function test_immutableAddresses() external view {
        assertEq(address(orbitPay.USDC()), address(usdc), "USDC address correct");
        assertEq(address(orbitPay.USDT()), address(usdt), "USDT address correct");
        assertEq(address(orbitPay.WETH()), address(weth), "WETH address correct");
        assertEq(orbitPay.FACTORY(), factory, "FACTORY address correct");
        assertEq(orbitPay.getForwarderAddress(), cre, "CRE address correct");
    }

    /* -------------------------------------------------------------------------- */
    /*                              getUserInfo                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test getUserInfo returns correct default values
     * @custom:when A user queries their info before choosing any token
     * @custom:then The function should return token as USDC (0) and lastPayment as 0
     */
    function test_getUserInfoDefault() public view {
        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);

        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.USDC), "default token is USDC");
        assertEq(userInfo.lastPayment, 0, "default lastPayment is 0");
    }

    /* -------------------------------------------------------------------------- */
    /*                              selectToken                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test choosing USDC as payment token
     * @custom:when A user calls selectToken with token id 0 (USDC)
     * @custom:then The transaction should succeed and return the USDC token contract
     * @custom:and The user's chosen token should be stored as USDC
     * @custom:and A SelectToken event should be emitted
     */
    function test_chosenTokenUSDC() public {
        vm.prank(user1);
        vm.expectEmit();
        emit IOrbitPay.SelectToken(user1, usdc);
        ERC20Mock token = ERC20Mock(address(orbitPay.selectToken(0)));

        assertEq(address(token), address(usdc), "returned token is USDC");

        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.USDC), "user token is USDC");
    }

    /**
     * @custom:scenario Test choosing USDT as payment token
     * @custom:when A user calls selectToken with token id 1 (USDT)
     * @custom:then The transaction should succeed and return the USDT token contract
     * @custom:and The user's chosen token should be stored as USDT
     * @custom:and A SelectToken event should be emitted
     */
    function test_chosenTokenUSDT() public {
        vm.prank(user1);
        vm.expectEmit();
        emit IOrbitPay.SelectToken(user1, usdt);
        ERC20Mock token = ERC20Mock(address(orbitPay.selectToken(1)));

        assertEq(address(token), address(usdt), "returned token is USDT");

        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.USDT), "user token is USDT");
    }

    /**
     * @custom:scenario Test choosing WETH as payment token
     * @custom:when A user calls selectToken with token id 2 (WETH)
     * @custom:then The transaction should succeed and return the WETH token contract
     * @custom:and The user's chosen token should be stored as WETH
     * @custom:and A SelectToken event should be emitted
     */
    function test_chosenTokenWETH() public {
        vm.prank(user1);
        vm.expectEmit();
        emit IOrbitPay.SelectToken(user1, weth);
        ERC20Mock token = ERC20Mock(address(orbitPay.selectToken(2)));

        assertEq(address(token), address(weth), "returned token is WETH");

        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.WETH), "user token is WETH");
    }

    /**
     * @custom:scenario Test switching token choice
     * @custom:when A user calls selectToken multiple times with different tokens
     * @custom:then The transaction should succeed and the user's chosen token should be updated
     */
    function test_switchTokenChoice() public {
        vm.prank(user1);
        orbitPay.selectToken(0);
        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.USDC), "user token is USDC");

        vm.prank(user1);
        orbitPay.selectToken(1);
        userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.USDT), "user token is USDT");

        vm.prank(user1);
        orbitPay.selectToken(2);
        userInfo = orbitPay.getUserInfo(user1);
        assertEq(uint256(userInfo.token), uint256(IOrbitPay.Token.WETH), "user token is WETH");
    }

    /**
     * @custom:scenario Test revert with invalid token id
     * @custom:when A user calls selectToken with an invalid token id (3)
     * @custom:then The transaction reverts with `IOrbitPayInvalidToken`
     */
    function test_revertWhen_chosenTokenInvalidToken() public {
        vm.prank(user1);
        vm.expectRevert(IOrbitPay.IOrbitPayInvalidToken.selector);
        orbitPay.selectToken(3);
    }

    /**
     * @custom:scenario Test revert with large invalid token id
     * @custom:when A user calls selectToken with a large invalid token id
     * @custom:then The transaction reverts with `IOrbitPayInvalidToken`
     */
    function test_revertWhen_chosenTokenLargeInvalidToken() public {
        vm.prank(user1);
        vm.expectRevert(IOrbitPay.IOrbitPayInvalidToken.selector);
        orbitPay.selectToken(type(uint256).max);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  pay                                       */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test pay function with single user
     * @custom:when The CRE contract calls pay with a single user and amount
     * @custom:then The transaction should succeed and tokens should be transferred from user to contract
     * @custom:and The user's lastPayment timestamp should be updated
     * @custom:and A Paid event should be emitted
     * @custom:and User balance should decrease and contract balance should increase
     */
    function test_paySingleUser() public {
        uint256 payAmount = 1000e6;

        vm.prank(user1);
        orbitPay.selectToken(0);

        vm.prank(user1);
        usdc.approve(address(orbitPay), payAmount);

        address[] memory users = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        users[0] = user1;
        amounts[0] = payAmount;

        uint256 userBalanceBefore = usdc.balanceOf(user1);
        uint256 contractBalanceBefore = usdc.balanceOf(address(orbitPay));

        vm.expectEmit();
        emit IOrbitPay.Paid(user1, payAmount, usdc);
        vm.prank(cre);
        _callOnReport(users, amounts);

        uint256 userBalanceAfter = usdc.balanceOf(user1);
        uint256 contractBalanceAfter = usdc.balanceOf(address(orbitPay));

        IOrbitPay.UserInfo memory userInfo = orbitPay.getUserInfo(user1);
        assertEq(userInfo.lastPayment, uint40(block.timestamp), "lastPayment updated");
        assertEq(userBalanceAfter, userBalanceBefore - payAmount, "user USDC balance decreased");
        assertEq(contractBalanceAfter, contractBalanceBefore + payAmount, "contract USDC balance increased");
    }

    /**
     * @custom:scenario Test pay function with multiple users
     * @custom:when The CRE contract calls pay with multiple users and amounts
     * @custom:then The transaction should succeed, tokens should be transferred from users to contract
     * @custom:and All users should have their lastPayment timestamp updated
     * @custom:and Paid events should be emitted for each user
     * @custom:and Each user's balance should decrease and contract balance should increase
     */
    function test_payMultipleUsers() public {
        uint256 payAmount1 = 1000e6;
        uint256 payAmount2 = 2000e6;
        uint256 payAmount3 = 500e18;

        vm.prank(user1);
        orbitPay.selectToken(0); // USDC
        vm.prank(user2);
        orbitPay.selectToken(1); // USDT
        vm.prank(user3);
        orbitPay.selectToken(2); // WETH

        vm.prank(user1);
        usdc.approve(address(orbitPay), payAmount1);
        vm.prank(user2);
        usdt.approve(address(orbitPay), payAmount2);
        vm.prank(user3);
        weth.approve(address(orbitPay), payAmount3);

        address[] memory users = new address[](3);
        uint256[] memory amounts = new uint256[](3);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;
        amounts[0] = payAmount1;
        amounts[1] = payAmount2;
        amounts[2] = payAmount3;

        uint256 user1UsdcBefore = usdc.balanceOf(user1);
        uint256 user2UsdtBefore = usdt.balanceOf(user2);
        uint256 user3WethBefore = weth.balanceOf(user3);
        uint256 contractUsdcBefore = usdc.balanceOf(address(orbitPay));
        uint256 contractUsdtBefore = usdt.balanceOf(address(orbitPay));
        uint256 contractWethBefore = weth.balanceOf(address(orbitPay));

        vm.expectEmit();
        emit IOrbitPay.Paid(user1, payAmount1, usdc);
        vm.expectEmit();
        emit IOrbitPay.Paid(user2, payAmount2, usdt);
        vm.expectEmit();
        emit IOrbitPay.Paid(user3, payAmount3, weth);

        vm.prank(cre);
        _callOnReport(users, amounts);

        IOrbitPay.UserInfo memory userInfo1 = orbitPay.getUserInfo(user1);
        IOrbitPay.UserInfo memory userInfo2 = orbitPay.getUserInfo(user2);
        IOrbitPay.UserInfo memory userInfo3 = orbitPay.getUserInfo(user3);

        assertEq(userInfo1.lastPayment, uint40(block.timestamp), "user1 lastPayment updated");
        assertEq(userInfo2.lastPayment, uint40(block.timestamp), "user2 lastPayment updated");
        assertEq(userInfo3.lastPayment, uint40(block.timestamp), "user3 lastPayment updated");

        assertEq(usdc.balanceOf(user1), user1UsdcBefore - payAmount1, "user1 USDC balance decreased");
        assertEq(usdt.balanceOf(user2), user2UsdtBefore - payAmount2, "user2 USDT balance decreased");
        assertEq(weth.balanceOf(user3), user3WethBefore - payAmount3, "user3 WETH balance decreased");
        assertEq(usdc.balanceOf(address(orbitPay)), contractUsdcBefore + payAmount1, "contract USDC balance increased");
        assertEq(usdt.balanceOf(address(orbitPay)), contractUsdtBefore + payAmount2, "contract USDT balance increased");
        assertEq(weth.balanceOf(address(orbitPay)), contractWethBefore + payAmount3, "contract WETH balance increased");
    }

    /**
     * @custom:scenario Test pay function handles transfer failures gracefully
     * @custom:when The CRE contract calls pay but some users lack approval
     * @custom:then The transaction should succeed, skip failed transfers, and continue with the next user
     * @custom:and Only successful transfers should update lastPayment and emit events
     */
    function test_paySkipsFailedTransfers() public {
        uint256 payAmount = 1000e6;

        vm.prank(user1);
        orbitPay.selectToken(0); // USDC
        vm.prank(user2);
        orbitPay.selectToken(0); // USDC

        // Only user1 approves
        vm.prank(user1);
        usdc.approve(address(orbitPay), payAmount);

        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        users[0] = user1;
        users[1] = user2;
        amounts[0] = payAmount;
        amounts[1] = payAmount;

        uint256 user1BalanceBefore = usdc.balanceOf(user1);
        uint256 user2BalanceBefore = usdc.balanceOf(user2);
        uint256 contractBalanceBefore = usdc.balanceOf(address(orbitPay));

        // Only user1 should emit Paid event
        vm.expectEmit();
        emit IOrbitPay.Paid(user1, payAmount, usdc);

        // This should not revert despite user2's transfer failing
        vm.prank(cre);
        _callOnReport(users, amounts);

        IOrbitPay.UserInfo memory userInfo1 = orbitPay.getUserInfo(user1);
        IOrbitPay.UserInfo memory userInfo2 = orbitPay.getUserInfo(user2);

        assertEq(userInfo1.lastPayment, uint40(block.timestamp), "user1 lastPayment updated");
        assertEq(userInfo2.lastPayment, 0, "user2 lastPayment not updated");

        assertEq(usdc.balanceOf(user1), user1BalanceBefore - payAmount, "user1 USDC balance decreased");
        assertEq(usdc.balanceOf(user2), user2BalanceBefore, "user2 USDC balance unchanged");
        assertEq(
            usdc.balanceOf(address(orbitPay)),
            contractBalanceBefore + payAmount,
            "contract USDC balance increased by user1 amount only"
        );
    }

    /**
     * @custom:scenario Test revert when pay arrays have mismatched lengths
     * @custom:when The CRE contract calls pay with different lengths of users and amounts
     * @custom:then The transaction reverts with `IOrbitPayLengthMismatch`
     */
    function test_revertWhen_payLengthMismatch() public {
        address[] memory users = new address[](2);
        uint256[] memory amounts = new uint256[](1);
        users[0] = user1;
        users[1] = user2;
        amounts[0] = 1000e6;

        vm.prank(cre);
        vm.expectRevert(IOrbitPay.IOrbitPayLengthMismatch.selector);
        _callOnReport(users, amounts);
    }

    /**
     * @custom:scenario Test revert when non-CRE address calls pay
     * @custom:when A non-CRE address calls the pay function
     * @custom:then The transaction reverts with `IOrbitPayCallerMustBeCRE`
     */
    function test_revertWhen_payCallerNotCRE() public {
        address[] memory users = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        users[0] = user1;
        amounts[0] = 1000e6;

        vm.prank(user1);
        vm.expectRevert();
        _callOnReport(users, amounts);
    }

    /**
     * @custom:scenario Test pay with empty arrays
     * @custom:when The CRE contract calls pay with empty users and amounts arrays
     * @custom:then The transaction should succeed without any effect
     */
    function test_payEmptyArrays() public {
        address[] memory users = new address[](0);
        uint256[] memory amounts = new uint256[](0);

        vm.prank(cre);
        _callOnReport(users, amounts);
    }

    /* -------------------------------------------------------------------------- */
    /*                             transferFund                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @custom:scenario Test transferFund transfers all token balances
     * @custom:when The owner calls transferFund with a recipient address
     * @custom:then The transaction should succeed and all token balances should be transferred
     * @custom:and The recipient should receive all tokens
     * @custom:and The contract's token balances should become zero
     */
    function test_transferFund() public {
        address recipient = address(0x5);
        uint256 usdcAmount = 1000e6;
        uint256 usdtAmount = 2000e6;
        uint256 wethAmount = 500e18;

        // Setup: mint tokens to contract
        usdc.mint(address(orbitPay), usdcAmount);
        usdt.mint(address(orbitPay), usdtAmount);
        weth.mint(address(orbitPay), wethAmount);

        uint256 recipientUsdcBefore = usdc.balanceOf(recipient);
        uint256 recipientUsdtBefore = usdt.balanceOf(recipient);
        uint256 recipientWethBefore = weth.balanceOf(recipient);

        vm.prank(orbitPay.owner());
        orbitPay.transferFund(recipient);

        assertEq(usdc.balanceOf(recipient), recipientUsdcBefore + usdcAmount, "recipient received USDC");
        assertEq(usdt.balanceOf(recipient), recipientUsdtBefore + usdtAmount, "recipient received USDT");
        assertEq(weth.balanceOf(recipient), recipientWethBefore + wethAmount, "recipient received WETH");
        assertEq(usdc.balanceOf(address(orbitPay)), 0, "contract USDC balance is zero");
        assertEq(usdt.balanceOf(address(orbitPay)), 0, "contract USDT balance is zero");
        assertEq(weth.balanceOf(address(orbitPay)), 0, "contract WETH balance is zero");
    }

    /**
     * @custom:scenario Test transferFund with partial balances
     * @custom:when The owner calls transferFund but only some tokens have balances
     * @custom:then The transaction should succeed and only tokens with balances should be transferred
     */
    function test_transferFundPartialBalances() public {
        address recipient = address(0x5);
        uint256 usdcAmount = 500e6;

        // Setup: mint only USDC to contract
        usdc.mint(address(orbitPay), usdcAmount);

        uint256 recipientUsdcBefore = usdc.balanceOf(recipient);
        uint256 recipientUsdtBefore = usdt.balanceOf(recipient);
        uint256 recipientWethBefore = weth.balanceOf(recipient);

        vm.prank(orbitPay.owner());
        orbitPay.transferFund(recipient);

        assertEq(usdc.balanceOf(recipient), recipientUsdcBefore + usdcAmount, "recipient received USDC");
        assertEq(usdt.balanceOf(recipient), recipientUsdtBefore, "recipient USDT balance unchanged");
        assertEq(weth.balanceOf(recipient), recipientWethBefore, "recipient WETH balance unchanged");
        assertEq(usdc.balanceOf(address(orbitPay)), 0, "contract USDC balance is zero");
        assertEq(usdt.balanceOf(address(orbitPay)), 0, "contract USDT balance is zero");
        assertEq(weth.balanceOf(address(orbitPay)), 0, "contract WETH balance is zero");
    }

    /**
     * @custom:scenario Test revert when non-owner calls transferFund
     * @custom:when A non-owner address calls transferFund
     * @custom:then The transaction reverts with unauthorized error
     */
    function test_revertWhen_transferFundNotOwner() public {
        address recipient = address(0x5);
        usdc.mint(address(orbitPay), 1000e6);

        vm.prank(user1);
        vm.expectRevert();
        orbitPay.transferFund(recipient);
    }

    /**
     * @custom:scenario Test transferFund with empty contract balances
     * @custom:when The owner calls transferFund but contract has no token balances
     * @custom:then The transaction should succeed without transferring anything
     */
    function test_transferFundEmptyBalances() public {
        address recipient = address(0x5);

        uint256 recipientUsdcBefore = usdc.balanceOf(recipient);
        uint256 recipientUsdtBefore = usdt.balanceOf(recipient);
        uint256 recipientWethBefore = weth.balanceOf(recipient);

        vm.prank(orbitPay.owner());
        orbitPay.transferFund(recipient);

        assertEq(usdc.balanceOf(recipient), recipientUsdcBefore, "recipient USDC balance unchanged");
        assertEq(usdt.balanceOf(recipient), recipientUsdtBefore, "recipient USDT balance unchanged");
        assertEq(weth.balanceOf(recipient), recipientWethBefore, "recipient WETH balance unchanged");
        assertEq(usdc.balanceOf(address(orbitPay)), 0, "contract USDC balance is zero");
        assertEq(usdt.balanceOf(address(orbitPay)), 0, "contract USDT balance is zero");
        assertEq(weth.balanceOf(address(orbitPay)), 0, "contract WETH balance is zero");
    }
}
