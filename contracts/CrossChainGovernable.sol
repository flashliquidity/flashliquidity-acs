//SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ICrossChainGovernable} from "./interfaces/ICrossChainGovernable.sol";

/**
 * @title CrossChainGovernable
 * @notice A 2-step cross-chain governable contract with a delay between setting the pending governor and transferring governance.
 */
abstract contract CrossChainGovernable is ICrossChainGovernable {
    error CrossChainGovernable__ZeroAddress();
    error CrossChainGovernable__ZeroChainSelector();
    error CrossChainGovernable__NotAuthorized();
    error CrossChainGovernable__TooEarly();

    address private s_governor;
    address private s_pendingGovernor;
    uint64 private s_governorChainSelector;
    uint64 private s_pendingGovernorChainSelector;
    uint64 private s_govTransferReqTimestamp;
    uint32 public constant TRANSFER_GOVERNANCE_DELAY = 3 days;

    event CrossChainGovernorChanged(address indexed newGovernor, uint64 indexed newGovernorChainSelector);
    event PendingGovernorChanged(address indexed pendingGovernor, uint64 indexed pendingGovernorChainSelector);
    event CommunicationLostIntervalChanged(uint32 indexed newInterval);

    modifier onlyCrossChainGovernor(address sender, uint64 chainId) {
        _revertIfNotCrossChainGovernor(sender, chainId);
        _;
    }

    constructor(address governor, uint64 governorChainSelector) {
        s_governor = governor;
        s_governorChainSelector = governorChainSelector;
        emit CrossChainGovernorChanged(governor, governorChainSelector);
    }

    /// @inheritdoc ICrossChainGovernable
    function setPendingGovernor(address pendingGovernor, uint64 pendingGovernorChainId) external virtual;

    /// @inheritdoc ICrossChainGovernable
    function transferGovernance() external virtual;

    /**
     * @param pendingGovernor The new pending governor
     * @param pendingGovernorChainSelector Then new pending governor chain selector
     * @dev revert if pending governor is address(0) or if chainSelector is zero
     */
    function _setPendingGovernor(address pendingGovernor, uint64 pendingGovernorChainSelector) internal {
        if (pendingGovernor == address(0)) revert CrossChainGovernable__ZeroAddress();
        if (pendingGovernorChainSelector == 0) revert CrossChainGovernable__ZeroChainSelector();
        s_pendingGovernor = pendingGovernor;
        s_pendingGovernorChainSelector = pendingGovernorChainSelector;
        s_govTransferReqTimestamp = uint64(block.timestamp);
        emit PendingGovernorChanged(pendingGovernor, pendingGovernorChainSelector);
    }

    /**
     * @dev revert if pending governor is not set or if governance transfer has been requested less than TRANSFER_GOVERNANCE_DELAY seconds ago.
     */
    function _transferGovernance() internal {
        address newGovernor = s_pendingGovernor;
        uint64 newGovernorChainSelector = s_pendingGovernorChainSelector;
        if (newGovernor == address(0)) revert CrossChainGovernable__ZeroAddress();
        if (block.timestamp - s_govTransferReqTimestamp < TRANSFER_GOVERNANCE_DELAY) revert CrossChainGovernable__TooEarly();
        s_pendingGovernor = address(0);
        s_governor = newGovernor;
        emit CrossChainGovernorChanged(newGovernor, newGovernorChainSelector);
    }

    function _revertIfNotCrossChainGovernor(address sender, uint64 chainSelector) internal view {
        if (sender != s_governor || chainSelector != s_governorChainSelector) revert CrossChainGovernable__NotAuthorized();
    }

    function _getGovernor() internal view returns (address) {
        return s_governor;
    }

    function _getGovernorChainSelector() internal view returns (uint64) {
        return s_governorChainSelector;
    }

    function _getPendingGovernor() internal view returns (address) {
        return s_pendingGovernor;
    }

    function _getPendingGovernorChainSelector() internal view returns (uint64) {
        return s_pendingGovernorChainSelector;
    }

    function _getGovTransferReqTimestamp() internal view returns (uint64) {
        return s_govTransferReqTimestamp;
    }

    function getGovernor() external view returns (address) {
        return _getGovernor();
    }

    function getGovernorChainSelector() external view returns (uint64) {
        return _getGovernorChainSelector();
    }

    function getPendingGovernor() external view returns (address) {
        return _getPendingGovernor();
    }

    function getPendingGovernorChainSelector() external view returns (uint64) {
        return _getPendingGovernorChainSelector();
    }

    function getGovTransferReqTimestamp() external view returns (uint64) {
        return _getGovTransferReqTimestamp();
    }
}
