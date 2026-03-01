// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin-contracts-5/token/ERC20/utils/SafeERC20.sol";
import { IERC165 } from "@openzeppelin-contracts-5/utils/introspection/IERC165.sol";

import { ReceiverTemplate } from "./ReceiverTemplate.sol";
import { IOrbitPay } from "./interfaces/IOrbitPay.sol";

/**
 * @title OrbitPay
 * @notice Handles automated ERC20 batch payments triggered by CRE reports.
 */
contract OrbitPay is IOrbitPay, ReceiverTemplate {
    using SafeERC20 for IERC20;

    IERC20 public immutable USDC;
    IERC20 public immutable USDT;
    IERC20 public immutable WETH;

    address public immutable FACTORY;

    mapping(address => UserInfo) internal _userInfo;

    constructor(address owner, address usdc, address usdt, address weth, address factory)
        ReceiverTemplate(owner, factory)
    {
        USDC = IERC20(usdc);
        USDT = IERC20(usdt);
        WETH = IERC20(weth);
        FACTORY = factory;
    }

    /* -------------------------------------------------------------------------- */
    /*                                   Getters                                  */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOrbitPay
    function getCRE() external view returns (address cre_) {
        cre_ = getForwarderAddress();
    }

    /// @inheritdoc IOrbitPay
    function getUserInfo(address user) external view returns (UserInfo memory userInfo_) {
        userInfo_ = _userInfo[user];
    }

    /* -------------------------------------------------------------------------- */
    /*                             External Functions                             */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOrbitPay
    function setCRE(address newCre) external {
        require(msg.sender == FACTORY, IOrbitPayCallerMustBeFactory());
        require(getForwarderAddress() == FACTORY, IOrbitPayCREAlreadySet());
        _setForwarderAddress(newCre);
    }

    /// @inheritdoc IOrbitPay
    function selectToken(uint256 token) external returns (IERC20 token_) {
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
    function onReport(bytes calldata metadata, bytes calldata report) public override(IOrbitPay, ReceiverTemplate) {
        if (msg.sender != getForwarderAddress()) {
            revert IOrbitPayCallerMustBeCRE();
        }
        super.onReport(metadata, report);
    }

    /* -------------------------------------------------------------------------- */
    /*                              Owner Functions                               */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOrbitPay
    function transferFund(address to) external onlyOwner {
        USDC.safeTransfer(to, USDC.balanceOf(address(this)));
        USDT.safeTransfer(to, USDT.balanceOf(address(this)));
        WETH.safeTransfer(to, WETH.balanceOf(address(this)));
    }

    /* -------------------------------------------------------------------------- */
    /*                             Internal Functions                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Decodes and processes the report payload from the CRE forwarder.
     * @param report The ABI-encoded users and amounts arrays.
     */
    function _processReport(bytes calldata report) internal override {
        (address[] memory users, uint256[] memory amounts) = abi.decode(report, (address[], uint256[]));
        _pay(users, amounts);
    }

    /**
     * @notice Processes batch payments by collecting tokens from each user.
     * @dev Raw `transferFrom` is used inside the `try` expression because `SafeERC20.safeTransferFrom`
     * is a library function and cannot be called in a `try` statement. Failed transfers are silently skipped.
     * @param users The list of user addresses to charge.
     * @param amounts The list of amounts to collect from each user.
     */
    function _pay(address[] memory users, uint256[] memory amounts) internal {
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
            } catch {}
        } while (++i < users.length);
    }

    /**
     * @notice Returns the token contract for a given Token enum value.
     * @param token The token enum value.
     * @return token_ The corresponding IERC20 token contract.
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

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view override(ReceiverTemplate, IERC165) returns (bool) {
        return interfaceId == type(IOrbitPay).interfaceId || super.supportsInterface(interfaceId);
    }
}
