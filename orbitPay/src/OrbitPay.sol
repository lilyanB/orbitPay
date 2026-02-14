// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";
import {Ownable2Step} from "@openzeppelin-contracts-5/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin-contracts-5/access/Ownable.sol";

import {IOrbitPay} from "./IOrbitPay.sol";

contract OrbitPay is IOrbitPay, Ownable2Step {
    /// @notice The ERC20 token contracts for USDC.
    IERC20 public immutable USDC;

    /// @notice The ERC20 token contracts for USDT.
    IERC20 public immutable USDT;

    /// @notice The ERC20 token contracts for WETH.
    IERC20 public immutable WETH;

    /// @notice The address of the CRE contract.
    address public immutable CRE;

    /// @dev Mapping to store the user info for each user.
    mapping(address => UserInfo) internal _userInfo;

    /**
     * @param owner The address of the initial owner of the contract.
     * @param usdc The address of the USDC token contract.
     * @param usdt The address of the USDT token contract.
     * @param weth The address of the WETH token contract.
     * @param cre The address of the CRE contract.
     */
    constructor(address owner, address usdc, address usdt, address weth, address cre) Ownable(owner) {
        USDC = IERC20(usdc);
        USDT = IERC20(usdt);
        WETH = IERC20(weth);
        CRE = cre;
    }

    /// @dev Modifier to restrict access to the CRE contract.
    modifier onlyCRE() {
        _checkCRE();
        _;
    }

    /// @dev Check if the caller is the CRE contract.
    function _checkCRE() internal view {
        require(msg.sender == CRE, IOrbitPayCallerMustBeCRE());
    }

    /// @inheritdoc IOrbitPay
    function getUserInfo(address user) external view returns (UserInfo memory userInfo_) {
        userInfo_ = _userInfo[user];
    }

    /// @inheritdoc IOrbitPay
    function chosenToken(uint256 token) external returns (IERC20 token_) {
        if (token == uint256(Token.USDC)) {
            _userInfo[msg.sender].token = Token.USDC;
            token_ = USDC;
        } else if (token == uint256(Token.USDT)) {
            _userInfo[msg.sender].token = Token.USDT;
            token_ = USDT;
        } else if (token == uint256(Token.WETH)) {
            _userInfo[msg.sender].token = Token.WETH;
            token_ = WETH;
        } else {
            revert IOrbitPayInvalidToken();
        }
        emit ChosenToken(msg.sender, token_);
    }

    /// @inheritdoc IOrbitPay
    function pay(address[] memory users, uint256[] memory amounts) external onlyCRE {
        require(users.length == amounts.length, IOrbitPayLengthMismatch());
        if (users.length == 0) return;
        uint256 i;
        do {
            UserInfo memory userInfo = _userInfo[users[i]];
            IERC20 tokenToUse = _getToken(userInfo.token);
            try tokenToUse.transferFrom(users[i], address(this), amounts[i]) returns (bool success) {
                if (success) {
                    _userInfo[users[i]].lastPayment = uint40(block.timestamp);
                    emit Paid(users[i], amounts[i], tokenToUse);
                }
            } catch {
                // If the transfer fails, we simply skip the user and continue with the next one.
            }
        } while (++i < users.length);
    }

    /// @inheritdoc IOrbitPay
    function transferFund(address to) external onlyOwner {
        USDC.transfer(to, USDC.balanceOf(address(this)));
        USDT.transfer(to, USDT.balanceOf(address(this)));
        WETH.transfer(to, WETH.balanceOf(address(this)));
    }

    /* -------------------------------------------------------------------------- */
    /*                                  Internal                                  */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Get the ERC20 token contract for a given Token enum.
     * @param token The Token enum value.
     * @return token_ The corresponding ERC20 token contract.
     */
    function _getToken(Token token) internal view returns (IERC20 token_) {
        if (token == Token.USDC) {
            token_ = USDC;
        } else if (token == Token.USDT) {
            token_ = USDT;
        } else {
            token_ = WETH;
        }
    }
}
