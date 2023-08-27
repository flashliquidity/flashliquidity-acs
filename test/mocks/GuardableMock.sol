// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Guardable} from "../../contracts/Guardable.sol";

contract GuardableMock is Guardable {
    constructor(address guardian) Guardable(guardian) {}

    function setGuardians(address[] calldata guardians, bool[] calldata enableds) external override {
        _setGuardians(guardians, enableds);
    }

    function shouldRevertIfNotGuardian() external onlyGuardian {}
}
