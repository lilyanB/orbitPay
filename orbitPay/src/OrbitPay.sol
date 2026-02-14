// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";

import {IOrbitPay} from "./IOrbitPay.sol";

contract OrbitPay is IOrbitPay {
    IERC20 public immutable USDC;

    IERC20 public immutable USDT;

    IERC20 public immutable WETH;

    address public immutable CRE;

    mapping(address => UserInfo) internal _userInfo;

    constructor(address _usdc, address _usdt, address _weth, address _cre) {
        USDC = IERC20(_usdc);
        USDT = IERC20(_usdt);
        WETH = IERC20(_weth);
        CRE = _cre;
    }

    modifier onlyCRE() {
        require(msg.sender == CRE, IOrbitPayCallerMustBeCRE());
        _;
    }

    ///@inheritdoc IOrbitPay
    function getUserInfo(address user) external view returns (UserInfo memory userInfo_) {
        userInfo_ = _userInfo[user];
    }

    ///@inheritdoc IOrbitPay
    function chosenToken(uint256 token) external returns (IERC20 token_) {
        if (token == uint256(Token.USDC)) {
            _userInfo[msg.sender].token = USDC;
            token_ = USDC;
        } else if (token == uint256(Token.USDT)) {
            _userInfo[msg.sender].token = USDT;
            token_ = USDT;
        } else if (token == uint256(Token.WETH)) {
            _userInfo[msg.sender].token = WETH;
            token_ = WETH;
        } else {
            revert IOrbitPayInvalidToken();
        }
        emit ChosenToken(msg.sender, token_);
    }

    ///@inheritdoc IOrbitPay
    function pay(address[] memory users, uint256[] memory amounts) external onlyCRE {
        require(users.length == amounts.length, IOrbitPayLengthMismatch());
        uint256 i;
        do {
            UserInfo memory userInfo = _userInfo[users[i]];
            if (address(userInfo.token) != address(0)) {
                try userInfo.token.transferFrom(users[i], address(this), amounts[i]) returns (bool success) {
                    if (success) {
                        _userInfo[users[i]].lastPayment = uint40(block.timestamp);
                        emit Paid(users[i], amounts[i], userInfo.token);
                    }
                } catch {
                    // If the transfer fails, we simply skip the user and continue with the next one.
                }
            }
        } while (i++ < users.length);
    }
}
