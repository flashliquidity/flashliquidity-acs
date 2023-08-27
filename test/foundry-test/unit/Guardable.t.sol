// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Guardable} from "../../../contracts/Guardable.sol";
import {GuardableMock} from "../../mocks/GuardableMock.sol";

contract GuardableTest is Test {
    GuardableMock public guardable;
    address public guardian = makeAddr("guardian");
    address public bob = makeAddr("bob");

    function setUp() public {
        guardable = new GuardableMock(guardian);
    }

    function testSetGuardians() public {
        assertTrue(guardable.isGuardian(guardian));
        assertFalse(guardable.isGuardian(bob));
        address[] memory newGuardians = new address[](2);
        bool[] memory enableds = new bool[](1);
        newGuardians[0] = guardian;
        newGuardians[1] = bob;
        enableds[0] = false;
        vm.expectRevert(Guardable.Guardable__ArrayLengthsMismatch.selector);
        guardable.setGuardians(newGuardians, enableds);
        enableds = new bool[](2);
        enableds[0] = false;
        enableds[1] = true;
        guardable.setGuardians(newGuardians, enableds);
        assertFalse(guardable.isGuardian(guardian));
        assertTrue(guardable.isGuardian(bob));
    }

    function testOnlyGuardian() public {
        vm.expectRevert(Guardable.Guardable__NotGuardian.selector);
        guardable.shouldRevertIfNotGuardian();
        vm.prank(guardian);
        guardable.shouldRevertIfNotGuardian();
    }
}
