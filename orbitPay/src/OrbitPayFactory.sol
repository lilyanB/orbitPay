// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC20} from "@openzeppelin-contracts-5/token/ERC20/IERC20.sol";
import {Ownable2Step} from "@openzeppelin-contracts-5/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin-contracts-5/access/Ownable.sol";

import {OrbitPay} from "./OrbitPay.sol";
import {IOrbitPay} from "./interfaces/IOrbitPay.sol";
import {IOrbitPayFactory} from "./interfaces/IOrbitPayFactory.sol";

contract OrbitPayFactory is IOrbitPayFactory, Ownable2Step {
    /// @notice The ERC20 token contracts for USDC.
    IERC20 public immutable USDC;

    /// @notice The ERC20 token contracts for USDT.
    IERC20 public immutable USDT;

    /// @notice The ERC20 token contracts for WETH.
    IERC20 public immutable WETH;

    /// @notice The address of the CRE contract.
    address public immutable CRE;

    /// @dev The ID of the next OrbitPay contract to be created.
    uint256 internal _orbitPayId;

    /// @dev Mapping to store the address of each OrbitPay contract by its ID.
    mapping(uint256 => address) internal _orbitPays;

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

    /// @inheritdoc IOrbitPayFactory
    function getOrbitPayId() external view returns (uint256 orbitPayId_) {
        orbitPayId_ = _orbitPayId;
    }

    /// @inheritdoc IOrbitPayFactory
    function getOrbitPay(uint256 orbitPayId) external view returns (address orbitPay_) {
        orbitPay_ = _orbitPays[orbitPayId];
    }

    /// @inheritdoc IOrbitPayFactory
    function createOrbitPay(address owner) external returns (IOrbitPay orbitPay_) {
        orbitPay_ = new OrbitPay(owner, address(USDC), address(USDT), address(WETH), address(this), CRE);
        _orbitPays[_orbitPayId] = address(orbitPay_);
        emit CreatedOrbitPay(_orbitPayId, address(orbitPay_));
        _orbitPayId++;
    }
}
