// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC165} from "@openzeppelin-contracts-5/utils/introspection/IERC165.sol";

interface IReceiver is IERC165 {
    function onReport(bytes calldata metadata, bytes calldata report) external;
}
