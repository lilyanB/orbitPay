// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IOrbitPay} from "./IOrbitPay.sol";

interface IOrbitPayFactory {
    event CreatedOrbitPay(uint256 indexed orbitPayId, address indexed orbitPay);

    /**
     * @notice Get the ID of the next OrbitPay contract to be created.
     * @return orbitPayId_ The ID of the next OrbitPay contract to be created.
     */
    function getOrbitPayId() external view returns (uint256 orbitPayId_);

    /**
     * @notice Get the address of an OrbitPay contract by its ID.
     * @param orbitPayId The ID of the OrbitPay contract.
     * @return orbitPay_ The address of the OrbitPay contract.
     */
    function getOrbitPay(uint256 orbitPayId) external view returns (address orbitPay_);

    /**
     * @notice Creates a new OrbitPay contract.
     * @param owner The address of the owner of the OrbitPay contract.
     * @param cre The address of the CRE contract from chainlink-cre-workflow.
     * @return orbitPay_ The address of the newly created OrbitPay contract.
     */
    function createOrbitPay(address owner, address cre) external returns (IOrbitPay orbitPay_);
}
