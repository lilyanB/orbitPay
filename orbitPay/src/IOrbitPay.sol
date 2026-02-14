// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";

interface IOrbitPay {
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
    /*                                    Error                                   */
    /* -------------------------------------------------------------------------- */

    error IOrbitPayInvalidToken();

    error IOrbitPayCallerMustBeCRE();

    error IOrbitPayLengthMismatch();

    /* -------------------------------------------------------------------------- */
    /*                                   Events                                   */
    /* -------------------------------------------------------------------------- */

    event ChosenToken(address indexed user, IERC20 token);

    event Paid(address indexed user, uint256 amount, IERC20 token);

    /* -------------------------------------------------------------------------- */
    /*                                  Functions                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Get the user info of a user.
     * @param user The address of the user.
     * @return userInfo_ The user info of the user.
     */
    function getUserInfo(address user) external view returns (UserInfo memory userInfo_);

    /**
     * @notice Choose the token to pay with.
     * @param token The token to pay with. 0 for USDC, 1 for USDT, 2 for WETH.
     * @return token_ The token chosen.
     */
    function chosenToken(uint256 token) external returns (IERC20 token_);

    /**
     * @notice The contract retrieves tokens from the users.
     * @param users The addresses of the users to retrieve tokens from.
     * @param amounts The amounts each user will pay to the contract.
     */
    function pay(address[] memory users, uint256[] memory amounts) external;
}
