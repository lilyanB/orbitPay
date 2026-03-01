// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin-contracts-5/utils/introspection/IERC165.sol";

/**
 * @title IOrbitPay
 * @notice Interface for the OrbitPay contract that handles automated ERC20 payments triggered by CRE reports.
 */
interface IOrbitPay is IERC165 {
    enum Token {
        USDC,
        USDT,
        WETH
    }

    struct UserInfo {
        Token token;
        uint40 lastPayment;
    }

    /* -------------------------------------------------------------------------- */
    /*                                   Errors                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice Thrown when an invalid token index is provided.
    error IOrbitPayInvalidToken();

    /// @notice Thrown when the caller is not the CRE forwarder contract.
    error IOrbitPayCallerMustBeCRE();

    /// @notice Thrown when the users and amounts arrays have different lengths.
    error IOrbitPayLengthMismatch();

    /// @notice Thrown when the CRE address has already been set.
    error IOrbitPayCREAlreadySet();

    /// @notice Thrown when the caller is not the factory contract.
    error IOrbitPayCallerMustBeFactory();

    /* -------------------------------------------------------------------------- */
    /*                                   Events                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Emitted when a user selects their preferred payment token.
     * @param user The address of the user.
     * @param token The selected token contract.
     */
    event SelectToken(address indexed user, IERC20 token);

    /**
     * @notice Emitted when a user is successfully charged.
     * @param user The address of the user.
     * @param amount The amount charged.
     * @param token The token used for payment.
     */
    event Paid(address indexed user, uint256 amount, IERC20 token);

    /* -------------------------------------------------------------------------- */
    /*                                  Functions                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The USDC token contract used for payments.
     * @return usdc_ The USDC token contract.
     */
    function USDC() external view returns (IERC20 usdc_);

    /**
     * @notice The USDT token contract used for payments.
     * @return usdt_ The USDT token contract.
     */
    function USDT() external view returns (IERC20 usdt_);

    /**
     * @notice The WETH token contract used for payments.
     * @return weth_ The WETH token contract.
     */
    function WETH() external view returns (IERC20 weth_);

    /**
     * @notice The factory contract address that bootstraps the CRE address.
     * @return factory_ The factory contract address.
     */
    function FACTORY() external view returns (address factory_);

    /**
     * @notice Get the user info of a user.
     * @param user The address of the user.
     * @return userInfo_ The user info of the user.
     */
    function getUserInfo(address user) external view returns (UserInfo memory userInfo_);

    /**
     * @notice Select the token to use for payments.
     * @param token The token index. 0 for USDC, 1 for USDT, 2 for WETH.
     * @return token_ The selected token contract.
     */
    function selectToken(uint256 token) external returns (IERC20 token_);

    /**
     * @notice Transfer all held funds from the contract to a specified address.
     * @dev Only the owner can call this function.
     * @param to The address to transfer the funds to.
     */
    function transferFund(address to) external;
}
