//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IGuardable {
    /**
     * @param guardians Array of addresses to enable/disable for the guardian role.
     * @param enableds Array of boolean values enabling or disabling the guardian role for each address in the guardians array.
     * @notice The guardians and enableds arrays must have the same length.
     */
    function setGuardians(address[] calldata guardians, bool[] calldata enableds) external;

    /**
     * @param guardian Address of guardian to curse.
     * @notice Only guardians that are not cursed can call this function.
     */
    function curse(address guardian) external;

    /**
     * @param guardian Address of guardian to revoke curse from.
     * @notice This function will revert if the target guardian has not been cursed.
     */
    function revokeCurse(address guardian) external;

    /**
     * @param caster Address of guardian that casted the curse to break.
     * @notice This function will revert if no curse has been casted against msg.sender from the caster address.
     * @notice The curse can only be broken if guardian role has been revoked from the curse caster.
     */
    function breakCurse(address caster) external;

    /**
     * @param guardian Address of guardian to check if has been cursed by the majority.
     * @notice The guardian is considered cursed if at least half (rounded up) of the guardians has cursed this address.
     */
    function isGuardianCursed(address guardian) external view returns (bool);

    function isGuardian(address guardian) external view returns (bool);
}
