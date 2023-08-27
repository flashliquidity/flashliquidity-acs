//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IGuardable} from "./interfaces/IGuardable.sol";

/**
 * @title Guardable
 */
abstract contract Guardable is IGuardable {
    error Guardable__NotGuardian();
    error Guardable__ArrayLengthsMismatch();

    mapping(address => bool) internal s_isGuardian;

    event GuardiansChanged(address[] indexed guardians, bool[] indexed enableds);

    modifier onlyGuardian() {
        _revertIfNotGuardian();
        _;
    }

    constructor(address guardian) {
        s_isGuardian[guardian] = true;
    }

    /// @inheritdoc IGuardable
    function setGuardians(address[] calldata guardians, bool[] calldata enableds) external virtual;

    /// @dev revert if guarians and enableds arrays are not the same length
    function _setGuardians(address[] calldata guardians, bool[] calldata enableds) internal {
        if (guardians.length != enableds.length) {
            revert Guardable__ArrayLengthsMismatch();
        }
        for (uint256 i; i < guardians.length;) {
            s_isGuardian[guardians[i]] = enableds[i];
            unchecked {
                ++i;
            }
        }
        emit GuardiansChanged(guardians, enableds);
    }

    function _revertIfNotGuardian() internal view {
        if (!s_isGuardian[msg.sender]) {
            revert Guardable__NotGuardian();
        }
    }

    function _isGuardian(address guardian) internal view returns (bool) {
        return s_isGuardian[guardian];
    }

    function isGuardian(address guardian) public view returns (bool) {
        return _isGuardian(guardian);
    }
}
