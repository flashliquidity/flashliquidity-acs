//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IGuardable} from "./interfaces/IGuardable.sol";

/**
 * @title Guardable
 */
abstract contract Guardable is IGuardable {
    error Guardable__NotGuardian();
    error Guardable__InconsistentParamsLength();
    error Guardable__CursedGuardian();
    error Guardable__InvalidCurseTarget();
    error Guardable__SelfCurse();
    error Guardable__AlreadyCursed();
    error Guardable__NotCursed();
    error Guardable__CannotBreakCurse();

    uint256 private s_guardianCount;
    mapping(address => bool) internal s_isGuardian;
    mapping(address guardian => uint256 curses) private s_curses;
    mapping(address guardianCursing => mapping(address guardianCursed => bool hasCursed)) private s_hasCursed;

    event GuardiansChanged(address[] indexed guardians, bool[] indexed enableds);
    event Cursed(address indexed cursed, address indexed caster);
    event CurseRevoked(address indexed cursed, address indexed caster);
    event CurseBroken(address indexed cursed, address indexed caster);

    modifier onlyGuardian() {
        _revertIfNotGuardian();
        _;
    }

    modifier onlyNotCursed() {
        _revertIfCursedGuardian();
        _;
    }

    constructor(address guardian) {
        s_isGuardian[guardian] = true;
        s_guardianCount = 1;
    }

    /// @inheritdoc IGuardable
    function setGuardians(address[] calldata guardians, bool[] calldata enableds) external virtual;

    /// @dev revert if guarians and enableds arrays are not the same length
    function _setGuardians(address[] calldata guardians, bool[] calldata enableds) internal {
        if (guardians.length != enableds.length) revert Guardable__InconsistentParamsLength();
        bool isAlreadyGuardian;
        bool isEnabled;
        address guardian;
        uint256 guardiansLength = guardians.length;
        for (uint256 i; i < guardiansLength;) {
            guardian = guardians[i];
            isAlreadyGuardian = s_isGuardian[guardian];
            isEnabled = enableds[i];
            if(isAlreadyGuardian && !isEnabled) {
                --s_guardianCount;
            } else if(!isAlreadyGuardian && isEnabled) {
                ++s_guardianCount;
            }
            s_isGuardian[guardian] = isEnabled;
            unchecked {
                ++i;
            }
        }
        emit GuardiansChanged(guardians, enableds);
    }

    /// @inheritdoc IGuardable
    function curse(address guardian) external onlyGuardian onlyNotCursed {
        if (_isGuardianCursed(msg.sender)) revert Guardable__CursedGuardian();
        if (!_isGuardian(guardian)) revert Guardable__InvalidCurseTarget();
        if (msg.sender == guardian) revert Guardable__SelfCurse();
        if (s_hasCursed[msg.sender][guardian]) revert Guardable__AlreadyCursed();
        s_hasCursed[msg.sender][guardian] = true;
        ++s_curses[guardian];
        emit Cursed(guardian, msg.sender);
    }

    /// @inheritdoc IGuardable
    function revokeCurse(address guardian) external onlyGuardian {
        if (_isGuardianCursed(msg.sender)) revert Guardable__CursedGuardian();
        if (!s_hasCursed[msg.sender][guardian]) revert Guardable__NotCursed();
        s_hasCursed[msg.sender][guardian] = false;
        --s_curses[guardian];
        emit CurseRevoked(guardian, msg.sender);
    }

    /// @inheritdoc IGuardable
    function breakCurse(address caster) external onlyGuardian {
        if (!s_hasCursed[caster][msg.sender]) revert Guardable__NotCursed();
        if (_isGuardian(caster)) revert Guardable__CannotBreakCurse();
        s_hasCursed[caster][msg.sender] = false;
        --s_curses[msg.sender];
        emit CurseBroken(msg.sender, caster);
    }

    function _revertIfNotGuardian() internal view {
        if (!s_isGuardian[msg.sender]) revert Guardable__NotGuardian();
    }

    function _revertIfCursedGuardian() internal view {
        if(_isGuardianCursed(msg.sender)) revert Guardable__CursedGuardian();
    }

    function _isGuardianCursed(address guardian) internal view returns (bool) {
        uint256 guardianCount = s_guardianCount;
        return s_curses[guardian] >= (guardianCount / 2) + (guardianCount % 2);
    }

    function _isGuardian(address guardian) internal view returns (bool) {
        return s_isGuardian[guardian];
    }

    function isGuardianCursed(address guardian) external view returns (bool) {
        return _isGuardianCursed(guardian);
    }

    function isGuardian(address guardian) external view returns (bool) {
        return _isGuardian(guardian);
    }
}
