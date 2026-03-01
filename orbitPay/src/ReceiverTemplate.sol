// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Ownable2Step} from "@openzeppelin-contracts-5/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin-contracts-5/access/Ownable.sol";
import {IERC165} from "@openzeppelin-contracts-5/utils/introspection/IERC165.sol";

import {IReceiver} from "./interfaces/IReceiver.sol";

abstract contract ReceiverTemplate is IReceiver, Ownable2Step {
    bytes private constant HEX_CHARS = "0123456789abcdef";

    address internal _forwarderAddress;
    address internal _expectedAuthor;
    bytes10 internal _expectedWorkflowName;
    bytes32 internal _expectedWorkflowId;

    error InvalidSender(address sender, address expected);
    error InvalidAuthor(address received, address expected);
    error InvalidWorkflowName(bytes10 received, bytes10 expected);
    error InvalidWorkflowId(bytes32 received, bytes32 expected);
    error WorkflowNameRequiresAuthorValidation();

    event ForwarderAddressUpdated(address indexed previousForwarder, address indexed newForwarder);
    event ExpectedAuthorUpdated(address indexed previousAuthor, address indexed newAuthor);
    event ExpectedWorkflowNameUpdated(bytes10 indexed previousName, bytes10 indexed newName);
    event ExpectedWorkflowIdUpdated(bytes32 indexed previousId, bytes32 indexed newId);
    event SecurityWarning(string message);

    constructor(address owner, address forwarderAddress) Ownable(owner) {
        _forwarderAddress = forwarderAddress;
        emit ForwarderAddressUpdated(address(0), forwarderAddress);
    }

    function getForwarderAddress() public view returns (address forwarderAddress_) {
        forwarderAddress_ = _forwarderAddress;
    }

    function getExpectedAuthor() public view returns (address expectedAuthor_) {
        expectedAuthor_ = _expectedAuthor;
    }

    function getExpectedWorkflowName() public view returns (bytes10 expectedWorkflowName_) {
        expectedWorkflowName_ = _expectedWorkflowName;
    }

    function getExpectedWorkflowId() public view returns (bytes32 expectedWorkflowId_) {
        expectedWorkflowId_ = _expectedWorkflowId;
    }

    function onReport(bytes calldata metadata, bytes calldata report) public virtual override {
        if (_forwarderAddress != address(0) && msg.sender != _forwarderAddress) {
            revert InvalidSender(msg.sender, _forwarderAddress);
        }

        if (_expectedWorkflowId != bytes32(0) || _expectedAuthor != address(0) || _expectedWorkflowName != bytes10(0)) {
            (bytes32 workflowId, bytes10 workflowName, address workflowOwner) = _decodeMetadata(metadata);

            if (_expectedWorkflowId != bytes32(0) && workflowId != _expectedWorkflowId) {
                revert InvalidWorkflowId(workflowId, _expectedWorkflowId);
            }

            if (_expectedAuthor != address(0) && workflowOwner != _expectedAuthor) {
                revert InvalidAuthor(workflowOwner, _expectedAuthor);
            }

            if (_expectedWorkflowName != bytes10(0)) {
                if (_expectedAuthor == address(0)) {
                    revert WorkflowNameRequiresAuthorValidation();
                }

                if (workflowName != _expectedWorkflowName) {
                    revert InvalidWorkflowName(workflowName, _expectedWorkflowName);
                }
            }
        }

        _processReport(report);
    }

    function setForwarderAddress(address newForwarder) public onlyOwner {
        _setForwarderAddress(newForwarder);
    }

    function setExpectedAuthor(address author) public onlyOwner {
        address previousAuthor = _expectedAuthor;
        _expectedAuthor = author;
        emit ExpectedAuthorUpdated(previousAuthor, author);
    }

    function setExpectedWorkflowName(string calldata name) public onlyOwner {
        bytes10 previousName = _expectedWorkflowName;

        if (bytes(name).length == 0) {
            _expectedWorkflowName = bytes10(0);
            emit ExpectedWorkflowNameUpdated(previousName, bytes10(0));
            return;
        }

        bytes32 hash = sha256(bytes(name));
        bytes memory hexString = _bytesToHexString(abi.encodePacked(hash));
        bytes memory first10 = new bytes(10);

        uint256 i;
        while (i < 10) {
            first10[i] = hexString[i];
            unchecked {
                ++i;
            }
        }

        _expectedWorkflowName = bytes10(first10);
        emit ExpectedWorkflowNameUpdated(previousName, _expectedWorkflowName);
    }

    function setExpectedWorkflowId(bytes32 workflowId) public onlyOwner {
        bytes32 previousId = _expectedWorkflowId;
        _expectedWorkflowId = workflowId;
        emit ExpectedWorkflowIdUpdated(previousId, workflowId);
    }

    function _setForwarderAddress(address newForwarder) internal {
        address previousForwarder = _forwarderAddress;
        if (newForwarder == address(0)) {
            emit SecurityWarning("Forwarder address set to zero - contract is now INSECURE");
        }
        _forwarderAddress = newForwarder;
        emit ForwarderAddressUpdated(previousForwarder, newForwarder);
    }

    function _bytesToHexString(bytes memory data) private pure returns (bytes memory) {
        bytes memory hexString = new bytes(data.length * 2);

        uint256 i;
        while (i < data.length) {
            hexString[i * 2] = HEX_CHARS[uint8(data[i] >> 4)];
            hexString[i * 2 + 1] = HEX_CHARS[uint8(data[i] & 0x0f)];
            unchecked {
                ++i;
            }
        }

        return hexString;
    }

    function _decodeMetadata(bytes memory metadata)
        internal
        pure
        returns (bytes32 workflowId, bytes10 workflowName, address workflowOwner)
    {
        assembly {
            workflowId := mload(add(metadata, 32))
            workflowName := mload(add(metadata, 64))
            workflowOwner := shr(mul(12, 8), mload(add(metadata, 74)))
        }
    }

    function _processReport(bytes calldata report) internal virtual;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}
