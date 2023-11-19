// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {CrossChainGovernable} from "../../contracts/CrossChainGovernable.sol";

contract CrossChainGovernableMock is CrossChainGovernable {
    constructor(address governor, uint64 governorChainSelector) CrossChainGovernable(governor, governorChainSelector) {}

    function setPendingGovernor(address pendingGovernor, uint64 pendingGovernorChainSelector) external override {
        _setPendingGovernor(pendingGovernor, pendingGovernorChainSelector);
    }

    function transferGovernance() external override {
        _transferGovernance();
    }

    function shouldRevertIfNotCrossChainGovernor(address sender, uint64 sourceChainSelector)
        external
        onlyCrossChainGovernor(sender, sourceChainSelector)
    {}
}
